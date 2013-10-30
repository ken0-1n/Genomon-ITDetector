#! /usr/loca/bin/perl

use strict;
use warnings;

my $fasta_tabular = $ARGV[0];

sub getTargetContig
{
  my ($in_tabular) = @_;
  my $tempScore = -1;
  my $targetContig = "";
  open(TABULAR, $in_tabular) || die "cannot open $!";
  while(<TABULAR>) {
    next if (/^\#/);
    s/[\r\n]//g;
    my @F = split("\t", $_);
    if ($F[11] > $tempScore ) {
      $targetContig = $F[1];
      last;
    }
  }
  close(TABULAR);
  return $targetContig;
}

my $targetContig = &getTargetContig($fasta_tabular);
print $targetContig;


