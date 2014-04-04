#! /usr/local/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my $sc_thres = $ARGV[1];
my $ins_size_thres = $ARGV[2];

open(IN, $input) || die "cannot open $input";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  my $chr   = $F[2];
  my $cigar = $F[5];
  my $chr_mate = $F[6];
  my $ins_size = $F[8];

  next if ((not defined $chr_mate) or (not defined $ins_size) or (not defined $ins_size_thres)); 
  
  next if ($chr =~ /\*/ or $chr_mate =~ /\*/);
  next if ($ins_size_thres <= abs($ins_size));
  
  my $seq  = $F[9];
  my $qual = $F[10];

  if ($cigar =~ /^(\d+)S/ ) {
    if ($1 >= $sc_thres) {
      my $tseq  = substr($seq,  0, $1);
      my $tqual = substr($qual, 0, $1);
      print ">" . join("~", @F[0 .. 8]) . "|" . $tseq . "|" . "+" . "|" . $tqual . "\n" . $tseq . "\n";
    }    
  }

  if ($cigar =~ /(\d+)S$/ ) {
    if ($1 >= $sc_thres) {
      my $tseq  = substr($seq,  -$1);
      my $tqual = substr($qual, -$1);
      print ">" . join("~", @F[0 .. 8]) . "|" . $tseq . "|" . "+" . "|" . $tqual . "\n" . $tseq . "\n";
    }
  }
}
close(IN);
        
