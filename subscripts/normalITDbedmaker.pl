#! /usr/local/bin/perl

use strict;
use warnings;

my $input_list = $ARGV[0];

open(INL, $input_list) || die "cannot open $input_list";
while(<INL>) {
  s/[\r\n\"]//g;
  my @filename_sample = split(",", $_);
  my $filename = $filename_sample[0];
  my $sample = $filename_sample[1];

  if (-f $filename) {
    open(IN, $filename) || die "cannot open $filename";
    while(<IN>) {
      s/[\r\n\"]//g;
      my @F = split("\t", $_);

      my $chr = $F[0];
      my $start = $F[1];
      my $end = $F[2];
      my $supportReads = $F[3];

      print $chr ."\t". $start ."\t". $end ."\t". $sample . $supportReads ."\n"; 
    }
    close(IN);
  }
}
close(INL);

