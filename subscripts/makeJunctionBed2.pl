#! /usr/loca/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my $sample_name = $ARGV[1];

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $p = $F[1];
    my $m = $F[2];
    my $supportRead = $p + $m;
    next if ( $supportRead < 3);

    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)\((\w*+)\)/;
    my $chr1 = $1;
    my $pos1 = $3;
    my $strand1 = $2;
    my $chr2 = $4;
    my $pos2 = $6;
    my $strand2 = $5;

    if ($strand1 eq "-" and $strand2 eq "+" and $pos1 < $pos2 and $chr1 eq $chr2) {
        if ($pos1 > 0 and $pos2 > 0) {
            print $chr1 ."\t". ($pos1-1) ."\t". $pos1 ."\t". $chr2 ."\t". ($pos2-1) ."\t". $pos2 ."\t". $sample_name."\t(".$p.",".$m.")\tleft\n";
        }
    }
    if ($strand1 eq "+" and $strand2 eq "-" and $pos1 > $pos2 and $chr1 eq $chr2) {
        if ($pos2 > 0 and $pos1 > 0) {
            print $chr1 ."\t". ($pos1-1) ."\t". $pos1 ."\t". $chr2 ."\t". ($pos2-1) ."\t". $pos2 ."\t". $sample_name."\t(".$p.",".$m.")\tright\n";
        }
    }
}
close(IN);

