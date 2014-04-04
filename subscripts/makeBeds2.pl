#! /usr/loca/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my $output1 = $ARGV[1];
my $output2 = $ARGV[2];
my $thres_min_length = $ARGV[3];
my $thres_max_length = $ARGV[4];

open(IN, $input) || die "cannot open $input";
open(OUT1, ">" . $output1) || die "cannot open $output1";
open(OUT2, ">" . $output2) || die "cannot open $output2";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)\((\w*+)\)/;
  my $chr1 = $1;
  my $pos1 = $3;
  my $strand1 = $2;
  my $chr2 = $4;
  my $pos2 = $6;
  my $strand2 = $5;

  next if ($chr1 ne $chr2);
    
  my $itd_length = (abs($pos1 - $pos2) + 1);
  if ($thres_min_length <= $itd_length and $itd_length <= $thres_max_length) {

    if ($strand1 eq "+" and $strand2 eq "-" and $pos1 > $pos2) {
      print OUT1 $chr1 ."\t". $pos2 ."\t". $pos1 ."\t". $F[0] ."\t". join("\t", @F[1 .. 3]) ."\n";
    }
    elsif ($strand1 eq "-" and $strand2 eq "+" and $pos1 < $pos2) { 
      print OUT2 $chr1 ."\t". $pos1 ."\t". $pos2 ."\t". $F[0] ."\t". join("\t", @F[1 .. 3]) ."\n";
    }
  }
}

close(IN);
close(OUT1);
close(OUT2);

