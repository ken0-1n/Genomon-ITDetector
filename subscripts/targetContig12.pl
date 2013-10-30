#! /usr/loca/bin/perl

use strict;
use warnings;

my $fasta_tabular = $ARGV[0];

sub getTargetContig
{
  my ($in_tabular) = @_;
  my $tempScore = 0;
  my $alignmentlen = 0;
  open(TABULAR, $in_tabular) || die "cannot open $!";
  while(<TABULAR>) {
    next if (/^\#/);
    s/[\r\n]//g;
    my @F = split("\t", $_);
    if ($F[11] > $tempScore ) {
      $alignmentlen = $F[3];
      last;
    }
  }
  close(TABULAR);
  return $alignmentlen;
}

my $alignmentlen = &getTargetContig($fasta_tabular);
print $alignmentlen;


