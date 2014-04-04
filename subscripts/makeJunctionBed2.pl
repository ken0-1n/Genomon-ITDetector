#! /usr/loca/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my $sample_name = $ARGV[1];
my $thres_min_length = $ARGV[2];
my $thres_max_length = $ARGV[3];

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $p = $F[1];
    my $m = $F[2];
    my $supportRead = $p + $m;
    next if ($supportRead <= 2);

    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)\((\w*+)\)/;
    my $chr1 = $1;
    my $pos1 = $3;
    my $strand1 = $2;
    my $chr2 = $4;
    my $pos2 = $6;
    my $strand2 = $5;
  
    next if ($chr1 ne $chr2);
    next if ($pos1 <= 0 or $pos2 <= 0);
  
    my $itd_length = (abs($pos1 - $pos2) + 1);
    if ($thres_min_length <= $itd_length and $itd_length <= $thres_max_length) {
  
        if ($strand1 eq "+" and $strand2 eq "-" and $pos1 > $pos2) {
            print $chr1 ."\t". $pos1 ."\t". $pos2 ."\t". $sample_name."\t(".$p.",".$m.")\tleft\n";
        }
        if ($strand1 eq "-" and $strand2 eq "+" and $pos1 < $pos2) {
            print $chr1 ."\t". $pos1 ."\t". $pos2 ."\t". $sample_name."\t(".$p.",".$m.")\tright\n";
        }
    }
}
close(IN);

