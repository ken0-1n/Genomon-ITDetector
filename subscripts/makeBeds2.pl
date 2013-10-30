#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];

my $output1 = $ARGV[1];
my $output2 = $ARGV[2];
my $output3 = $ARGV[3];
my $output4 = $ARGV[4];
my $ad_range = $ARGV[5];

my $chr1 = "";
my $pos1 = "";
my $strand1 = "";
my $chr2 = "";
my $pos2 = "";
my $strand2 = "";
my $bases = "";

open(IN, $input) || die "cannot open $!";
open(OUT1, ">" . $output1) || die "cannot open $!";
open(OUT2, ">" . $output2) || die "cannot open $!";
open(OUT3, ">" . $output3) || die "cannot open $!";
open(OUT4, ">" . $output4) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)\((\w*+)\)/;
    $chr1 = $1;
    $pos1 = $3;
    $strand1 = $2;
    $chr2 = $4;
    $pos2 = $6;
    $strand2 = $5;
    $bases = $7;
    my $blen = length($bases);

    if ($strand1 eq "+" and $strand2 eq "-" and $pos1 > $pos2 and $chr1 eq $chr2) {
        print OUT1 $chr1 ."\t". max(0, $pos1 - $ad_range + $blen) ."\t". ($pos1 + $ad_range + $blen) ."\t". $F[0] ."\t". join("\t", @F[1 .. 3]) ."\n";
        print OUT2 $chr2 ."\t". max(0, $pos2) ."\t". ($pos2) ."\t". $F[0] ."\t". join("\t", @F[1 .. 3]) . "\n";
    
    } elsif ($strand1 eq "-" and $strand2 eq "+" and $pos1 < $pos2 and $chr1 eq $chr2) { 
        print OUT3 $chr1 ."\t". max(0, $pos1 - $ad_range) ."\t". ($pos1 + $ad_range) ."\t". $F[0] ."\t". join("\t", @F[1 .. 3]) ."\n";
        print OUT4 $chr2 ."\t". max(0, $pos2 + $blen) ."\t". ($pos2 + $blen) ."\t". $F[0] ."\t". join("\t", @F[1 .. 3]) . "\n";
    }
}

close(IN);
close(OUT1);
close(OUT2);
close(OUT3);
close(OUT4);

