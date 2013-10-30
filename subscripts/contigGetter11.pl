#! /usr/loca/bin/perl

use strict;
use warnings;

my $targetContig = $ARGV[0];
my $cap_contigs = $ARGV[1];

sub getContigSeq
{
  my ($in_contigs, $target_contig) = @_;
  open(IN_CONTIGS, $in_contigs) || die "cannot open $!";
  while(<IN_CONTIGS>) {
    s/[\r\n]//g;
    last if ($_ =~ /$target_contig/);
  }
  my $contigSeq = "";
  while(<IN_CONTIGS>) {
    s/[\r\n]//g;
    last if ($_ =~ /^>/);
    $contigSeq = $contigSeq . $_;
  }
  close(IN_CONTIGS);
  return $contigSeq;
} 
my $contigSeq = &getContigSeq($cap_contigs, $targetContig);
print $contigSeq;


