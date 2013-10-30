#! /usr/loca/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];

my $flg = 0;
open(IN, $input) || die "cannot open $input";
while(<IN>) {
  next if (/^\#/);
  s/[\r\n]//g;
  if ($_ =~ /^>Contig2/){
    $flg = 1;
  }
  if ($_ =~ /^>Contig3/){
    $flg = 2;
    last;
  }
}
close(IN);
print $flg;

