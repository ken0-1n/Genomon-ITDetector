#! /usr/local/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];

open(IN, $input) || die "cannot open $input";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $itdselect = $F[12];

    my $chr = "";
    my $spos = 0;
    my $epos = 0;

    my $p1 = $F[1];
    my $m1 = $F[2];
    my $p2 = $F[4];
    my $m2 = $F[5];

    if ($itdselect == 1) { 
      $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)\((\w*+)\)/;
      $chr = $1;
      $spos = $6;
      $epos = $3;
    }
    else {
      $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)\((\w*+)\)/;
      $chr = $1;
      $spos = $3;
      $epos = $6;
    }
    print $chr ."\t". ($spos-5) ."\t". ($spos+5) ."\t(".$p1.",".$m1.",".$p2.",".$m2 .")\n"; 
    print $chr ."\t". ($epos-5) ."\t". ($epos+5) ."\t(".$p1.",".$m1.",".$p2.",".$m2 .")\n"; 
}
close(IN);

