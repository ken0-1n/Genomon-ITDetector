#! /usr/local/bin/perl

use strict;
use warnings;

my $input_psl = $ARGV[0];
my $output_juncCount = $ARGV[1];
my $output_juncID = $ARGV[2];
my $multiThres = $ARGV[3]; # if the read is mapped to more than this parameter value then skip this read
my $juncInsertionThres = $ARGV[4]; # ignore junction where more than this parameter of inserted bases


my %junc2count = ();
my %junc2ID = ();

my $tempID = "";
my @tempRecords = ();

open(IN, $input_psl) || die "cannot open $!";
while(<IN>) {

    next if (not $_ =~ /^\d/);

    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if ($F[9] ne $tempID) {
        if ($#tempRecords >= 0 and $#tempRecords + 1 <= $multiThres) {
            foreach my $record (@tempRecords) {
                &procRecords($record);
            } 
        }
        $tempID = $F[9];
        @tempRecords = ();
        push @tempRecords, join("\t", @F);

    } else {
        push @tempRecords, join("\t", @F);
    }
}
close(IN);

if ($#tempRecords >= 0 and $#tempRecords + 1 <= $multiThres) {
    foreach my $record (@tempRecords) {
        &procRecords($record);
    }   
}

open(OUT1, ">" . $output_juncCount) || die "cannot open $!";
open(OUT2, ">" . $output_juncID) || die "cannot open $!";
foreach my $key (sort keys %junc2count) {
    print OUT1 $key . "\t" . $junc2count{$key}->[0] . "\t" . $junc2count{$key}->[1] . "\t" . $junc2ID{$key} . "\n";
    print OUT2 $key . "\t" . $junc2ID{$key} . "\n";
}

sub procRecords {
    return if (not defined $_);
    s/[\r\n\"]//g;
    my @F = split("\t", $_[0]);
    (my $Qname, my $Qseq, my $QID2, my $Qqual) = split("\\|", $F[9]);    
    my @Qname = split("~", $Qname);
    my @flags = split("", sprintf("%011b", $Qname[1]));


####################
# get information for original junction points
# junction information is $chr1:$dir1$pos1-$chr2:$dir2$pos2($clip2)

    my $length1 = 0;
    while($Qname[5] =~ /(\d+)[MDN]/g) {
        $length1 = $length1 + $1;
    }

    my $chr1 = $Qname[2];
    my $pos1 = "";
    my $dir1 = "";

    if ($Qname[5] =~ /^\d+S/) {
        $pos1 = $Qname[3];
        $dir1 = "-";
    } 
    if ($Qname[5] =~ /\d+S$/) {
        $pos1 = $Qname[3] + $length1 - 1;
        $dir1 = "+";
    }

####################
# get information for the target mapped region

    my $chr2 = $F[13];
    my $pos2 = "";
    my $dir2 = "";
    my $clip2 = 0;

    my $length2 = $F[16] - $F[15];


    if  (($dir1 eq "+" and $F[8] eq "+") or ($dir1 eq "-" and $F[8] eq "-")) {
        $pos2 = $F[15] + 1;
        $dir2 = "-";
    }

    if (($dir1 eq "+" and $F[8] eq "-") or ($dir1 eq "-" and $F[8] eq "+")) {
        $pos2 = $F[16];
        $dir2 = "+";
    } 

    if ($dir1 eq "-") {
        $clip2 = substr($Qseq, $F[12], $F[10] - $F[12]);
    }
    
    if ($dir1 eq "+") {
        $clip2 = substr($Qseq, 0, $F[11]);
    }

    return if (length($clip2) > $juncInsertionThres);


#####################
# get information for the pair reads

    my $pair1_chr = $Qname[2];
    my $pair1_pos = $Qname[3];
    my $pair1_strand = $flags[-5] == 1 ? "-" : "+";

    my $pair2_chr = $Qname[6] eq "=" ? $pair1_chr : $Qname[6];
    my $pair2_pos = $Qname[7];
    my $pair2_strand = $flags[-6] == 1 ? "-" : "+";

    my $isProper = $flags[-2];
    my $insertSize = $Qname[8];


    my $key = $chr1 . ":" . $dir1 . $pos1 . "-" . $chr2 . ":" . $dir2 . $pos2 . "(" . $clip2 . ")";

    # check the consistency
    my $cons1 = 0;
    my $cons2 = 0;

    if ($chr1 eq $pair2_chr and $isProper == 1) {
        if ($dir1 eq "+") {
            if ($pair2_pos >= $pos1 - 500000 and $pair2_pos < $pos1 + 10) {
                $cons1 = 1;
            }
        } else {
            # if ($pair2_pos > $pos1 and $pair2_pos <= $pos1 + 500000) {
            if ($pair1_pos + $insertSize > $pos1 - 10 and $pair1_pos + $insertSize <= $pos1 + 500000) { 
                $cons1 = 1;
            }
        }
    }
 
    if ( ($chr2 eq $pair2_chr) and ( ($dir2 eq "+" and $pair2_strand eq "+") or ($dir2 eq "-" and $pair2_strand eq "-") ) )  {

        if ($dir2 eq "+") {
            if ($pair2_pos >= $pos2 - 500000 and $pair2_pos < $pos2 + 10) {
                $cons2 = 1;
            }
        } else {
        if ($pair2_pos > $pos2 - 10 and $pair2_pos <= $pos2 + 500000) {
                $cons2 = 1;
            }
        }
    }
 
    if ($cons1 == 1) {

        if (not exists $junc2count{$key}) {
            $junc2count{$key} = [(0) x 2];
        }
        $junc2count{$key}->[0] = $junc2count{$key}->[0] + 1;

        if (not exists $junc2ID{$key}) {
            $junc2ID{$key} = $Qname[0] . "," . $Qseq;
        } else {
            $junc2ID{$key} = $junc2ID{$key} . "," . $Qname[0] . "," . $Qseq;
        }
        
    } elsif ($cons2 == 1) {

        if (not exists $junc2count{$key}) { 
            $junc2count{$key} = [(0) x 2];
        }
        $junc2count{$key}->[1] = $junc2count{$key}->[1] + 1;

        if (not exists $junc2ID{$key}) {
            $junc2ID{$key} = $Qname[0] . "," . $Qseq;
        } else {
            $junc2ID{$key} = $junc2ID{$key} . "," . $Qname[0] . "," . $Qseq;
        }
    }
}


