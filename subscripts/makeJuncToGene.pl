#! /usr/local/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my %junc2gene = ();

open(IN, $input) || die "cannot open $!";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  my $key = $F[0]."\t".$F[1]."\t".$F[2];

  if (not exists $junc2gene{$key}) {
    $junc2gene{$key} = $F[3];
  } else {
    $junc2gene{$key} = $junc2gene{$key} . ";" . $F[3];
  } 
}
close(IN);

foreach my $junc (sort keys %junc2gene) {
  print $junc . "\t" . $junc2gene{$junc} . "\n";
}

