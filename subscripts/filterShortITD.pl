#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];
my $filtMinNum = $ARGV[1];
my $filtMaxNum = $ARGV[2];
my $output = $ARGV[3];

open(OUT, ">".$output) || die "cannot open $!";
open(IN, $input) || die "cannot open $!";
while(<IN>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_;

  $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
  my $chr11 = $1;
  my $pos11 = $3 ;
  my $strand11 = $2;
  my $chr12 = $4;
  my $pos12 = $6;
  my $strand12 = $5;

  $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
  my $chr21 = $1;
  my $pos21 = $3;
  my $strand21 = $2;
  my $chr22 = $4;
  my $pos22 = $6;
  my $strand22 = $5;

  my $pos1 = (abs($pos11 - $pos12) + 1);
  my $pos2 = (abs($pos21 - $pos22) + 1);

  # filter 1 base read
  if (($pos1 >= $filtMinNum and $pos2 >= $filtMinNum)
   and ($pos1 <= $filtMaxNum and $pos2 <= $filtMaxNum)) {
    print OUT $line ."\n";
  }
}
close(IN);
close(OUT);

