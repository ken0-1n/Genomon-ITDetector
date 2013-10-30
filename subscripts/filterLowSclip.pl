#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];
my $filtNum = $ARGV[1];
my $output = $ARGV[2];

open(OUT, ">".$output) || die "cannot open $!";
open(IN, $input) || die "cannot open $!";
while(<IN>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_; 
  my $sclipNum1 = ($F[1] + $F[2]);
  my $sclipNum2 = ($F[4] + $F[5]);

  # filter 1 base read
  next if ($sclipNum1 <= $filtNum and $sclipNum2 <= $filtNum);
  print OUT $line ."\n";
}
close(IN);
close(OUT);

