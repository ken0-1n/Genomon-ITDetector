#! /usr/local/bin/perl
use strict;
use warnings;

my $input = $ARGV[0];
my $sample_name = $ARGV[1];

open(IN, $input) || die "cannot open $input";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $itdleft = $F[0];
    my $itdright = $F[3];
    my $p1 = $F[1];
    my $m1 = $F[2];
    my $p2 = $F[4];
    my $m2 = $F[5];
    
    print $itdleft."\t".$itdright."\t".$sample_name."\t(".$p1.",".$m1.",".$p2.",".$m2.")\n";
}
close(IN);

