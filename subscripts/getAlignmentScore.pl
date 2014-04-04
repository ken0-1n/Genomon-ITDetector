#! /usr/loca/bin/perl

use strict;
use warnings;

my $fasta_tabular = $ARGV[0];

sub getTargetContig
{
  my ($in_tabular) = @_;
  my $tempScore = 0;
  my $tempAlignmentlen = 0;
  my $tempSelectPDN = "";
  open(TABULAR, $in_tabular) || die "cannot open $!";
  while(<TABULAR>) {
    next if (/^\#/);
    
    s/[\r\n]//g;
    my @F = split("\t", $_);
    
    if ($F[11] > $tempScore ) {
      $tempAlignmentlen = $F[3];
      $tempScore = $F[11];
      $tempSelectPDN = $F[1];
    }
  }
  close(TABULAR);
  return $tempSelectPDN."\t".$tempAlignmentlen;
}

my $alignmentlen = &getTargetContig($fasta_tabular);
print $alignmentlen;


