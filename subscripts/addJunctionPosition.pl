#! /usr/loca/bin/perl

use strict;
use warnings;

my $input_list = $ARGV[0];
my $output_bed = $ARGV[1];
my $output = $ARGV[2];

open(OUTBED, ">" . $output_bed) || die "cannot open $output_bed";
open(OUT, ">" . $output) || die "cannot open $output";
open(IN, $input_list) || die "cannot open $!";
while(<IN>) {
  s/[\r\n]//g;
  my $line = $_;
  my @F = split("\t", $_);
  my $PDN_select = $F[17];

  my $chr = "";
  my $start = 0;
  my $end = 0;
   
  if ($PDN_select eq "PDN1") {
    $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    $chr = $1;
    $end = $3;
    $start = $6;
  }
  else {
    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    $chr = $1;
    $start = $3;
    $end = $6;
  }
    
  print OUTBED $chr."\t".($start - 1)."\t".$end."\n";
  print OUT $chr."\t".$start."\t".$end."\t".$line."\n";
}
close(IN);

