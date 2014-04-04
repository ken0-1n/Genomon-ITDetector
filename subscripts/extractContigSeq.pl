#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_contigs = $ARGV[0];
my $input_fasta = $ARGV[1];


my %contig2length = ();
my $tempContig = "";
my $tempSeq = "";

open(IN, $input_contigs) || die "cannot open $!";
while(<IN>) {
  s/[\r\n]//g;

  if (s/^>//) {
    if ($tempSeq ne "") {
      $contig2length{$tempContig} = length($tempSeq);
    }  
    $tempContig = $_;
    $tempSeq = "";
  }
  else {
    $tempSeq = $tempSeq . $_;
  }
}

if ($tempSeq ne "") {
    $contig2length{$tempContig} = length($tempSeq);
}
close(IN);    

$tempContig = "";
my $tempScore = -1;
my $tempStrand = "+";
my $tempLength = 0;

open(IN, $input_fasta) || die "cannot open $!";
while(<IN>) {
  next if (/^\#/);

  s/[\r\n]//g;
  my @F = split("\t", $_);
    
  if ($F[11] > $tempScore or $F[11] >= $tempScore and $contig2length{$F[0]} > $tempLength) {

    $tempScore = $F[11];
    $tempContig = $F[0];
    $tempLength = $contig2length{$F[0]};

    if ($F[6] < $F[7]) {
      $tempStrand = "+";
    }
    else {
      $tempStrand = "-";
    }
  }
}
close(IN);

my $selectedContig = $tempContig;
my $strand = $tempStrand;
my $contigSeq = "";

open(IN, $input_contigs) || die "cannot open $!";
while(<IN>) {
  s/[\r\n]//g;
  last if ($_ =~ /$selectedContig/);
}
while(<IN>) {
  s/[\r\n]//g;
  last if ($_ =~ /^>/);
  if ($contigSeq eq "") {
    $contigSeq = $_;
  }
  else {
    $contigSeq = $contigSeq . $_;
  }
}
close(IN);
  
my $seq = $strand eq "+" ? $contigSeq : &complementSeq($contigSeq);
print $seq ."\n";

sub complementSeq {
  my $tseq = reverse($_[0]);
  $tseq =~ s/A/S/g;
  $tseq =~ s/T/A/g;
  $tseq =~ s/S/T/g;
  $tseq =~ s/C/S/g;
  $tseq =~ s/G/C/g;
  $tseq =~ s/S/G/g;
  return $tseq;
}

