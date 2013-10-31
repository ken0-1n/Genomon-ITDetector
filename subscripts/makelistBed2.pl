#! /usr/local/bin/perl

use strict;

my $input_list = $ARGV[0];
my $output1_bed = $ARGV[1];
my $output2_bed = $ARGV[2];

open(OUT1, ">".$output1_bed) || die "cannot open $!";
open(OUT2, ">".$output2_bed) || die "cannot open $!";
open(INL, $input_list) || die "cannot open $!";
while(<INL>) {

    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $key = $F[0]."\t".$F[3];
    my $itdselect = $F[11];
      
    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    my $rchr1 = $1;
    my $rbp1 = $3;
    my $rchr2 = $4;
    my $rbp2 = $6;
    $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    my $lchr1 = $1;
    my $lbp1 = $3;
    my $lchr2 = $4;
    my $lbp2 = $6;
   
    if ($lbp1 > 0 and $lbp2 > 0) {
      print OUT1 $lchr1 ."\t". ($lbp1-1) ."\t". $lbp1 ."\t". $lchr2 ."\t". ($lbp2-1) ."\t". $lbp2 ."\t". $key . "\n"; 
    }
    if ($rbp2 > 0 and $rbp2 > 0) {
      print OUT2 $rchr1 ."\t". ($rbp1-1) ."\t". $rbp1 ."\t". $rchr2 ."\t". ($rbp2-1) ."\t". $rbp2 ."\t". $key . "\n"; 
    }
}
close(INL);
close(OUT1);
close(OUT2);

