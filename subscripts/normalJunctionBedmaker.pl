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

  my $idx = 11;
  if ( 2 == $#filename_sample) {
    $idx = $filename_sample[2];
  }

  open(IN, $filename) || die "cannot open $filename";
  while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $itdselect = $F[$idx];

    my $chr = "";
    my $spos = 0;
    my $epos = 0;

    my $p1 = $F[1];
    my $m1 = $F[2];
    my $p2 = $F[4];
    my $m2 = $F[5];

    if ($itdselect == 1) { 
      $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      $chr = $1;
      $spos = $6 - 1;
      $epos = $3;
    }
    else {
      $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      $chr = $1;
      $spos = $3 - 1;
      $epos = $6;
    }
    print $chr ."\t". ($spos-4) ."\t". ($spos+6) ."\t". $sample ."(".$p1.",".$m1.",".$p2.",".$m2 .")\t". $F[3]. "\n"; 
    print $chr ."\t". ($epos-5) ."\t". ($epos+5) ."\t". $sample ."(".$p1.",".$m1.",".$p2.",".$m2 .")\t". $F[3]. "\n"; 
  }
  close(IN);
}
close(INL);

