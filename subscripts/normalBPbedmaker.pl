#! /usr/local/bin/perl

use strict;
use warnings;

my $input_list = $ARGV[0];
my $output1_bed = $ARGV[1];
my $output2_bed = $ARGV[2];
my $sample_args = $ARGV[3];

open(OUT1, ">".$output1_bed) || die "cannot open $!";
open(OUT2, ">".$output2_bed) || die "cannot open $!";
open(INL, $input_list) || die "cannot open $input_list";
while(<INL>) {
  s/[\r\n\"]//g;
  my $filename = $_;

  if (-f $filename) {
    open(IN, $filename) || die "cannot open $filename";
    while(<IN>) {
      s/[\r\n\"]//g;
      my @F = split("\t", $_);

      my $chr1 = $F[0];
      my $spos1 = $F[1];
      my $epos1 = $F[2];
      my $chr2 = $F[3];
      my $spos2 = $F[4];
      my $epos2 = $F[5];
      my $sample = $F[6];
      my $supportReads = $F[7];
      my $left_or_right = $F[8];
     
      if ($sample ne $sample_args) { 
        if ($left_or_right eq "left") {
          print OUT1 $chr1 ."\t". $spos1 ."\t". $epos1 ."\t". $chr2 ."\t". $spos2 ."\t". $epos2 ."\t". $sample.$supportReads ."\n";
        }
        elsif ($left_or_right eq "right") {
          print OUT2 $chr1 ."\t". $spos1 ."\t". $epos1 ."\t". $chr2 ."\t". $spos2 ."\t". $epos2 ."\t". $sample.$supportReads ."\n";
        }
      }
    }
    close(IN);
  }
}
close(INL);
close(OUT1);
close(OUT2);

