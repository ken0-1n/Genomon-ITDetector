#! /usr/local/bin/perl

use strict;
use warnings;

my $input_list = $ARGV[0];

open(INL, $input_list) || die "cannot open $input_list";
while(<INL>) {
  s/[\r\n\"]//g;
  my $filename = $_;

  if (-f $filename) {
    open(IN, $filename) || die "cannot open $filename";
    while(<IN>) {
      s/[\r\n\"]//g;
      my @F = split("\t", $_);

      $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      my $lchr1 = $1;
      my $lbp1 = $3;
      my $lchr2 = $4;
      my $lbp2 = $6;
      $F[1] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      my $rchr1 = $1;
      my $rbp1 = $3;
      my $rchr2 = $4;
      my $rbp2 = $6;
      
      my $itdleft = $F[0];
      my $itdright = $F[1];
      my $sample = $F[2];
      my $supportReads = $F[3];

      print $lchr1 ."\t". $lbp1 ."\t". $lbp2 ."\t". $itdleft ."\t".  $rchr1 ."\t". $rbp1 ."\t". $rbp2 ."\t". $itdright ."\t". $sample ."\t". $supportReads ."\n"; 
    }
    close(IN);
  }
}
close(INL);

