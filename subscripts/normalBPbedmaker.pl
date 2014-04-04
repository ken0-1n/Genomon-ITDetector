#! /usr/local/bin/perl

use strict;

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

      my $chr  = $F[0];
      my $pos1 = $F[1];
      my $pos2 = $F[2];
      my $sample = $F[3];
      my $supportReads = $F[4];
      my $left_or_right = $F[5];
     
      if ($sample ne $sample_args) { 
        if ($left_or_right eq "left") {
          print OUT1 $chr ."\t". $pos1 ."\t". $pos2 ."\t". $sample.$supportReads ."\n";
        }
        elsif ($left_or_right eq "right") {
          print OUT2 $chr ."\t". $pos1 ."\t". $pos2 ."\t". $sample.$supportReads ."\n";
        }
      }
    }
    close(IN);
  }
}
close(INL);
close(OUT1);
close(OUT2);

