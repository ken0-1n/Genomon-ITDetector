#! /usr/loca/bin/perl

use strict;
use warnings;

my $inputlist = $ARGV[0];
my $inputsam = $ARGV[1];

my %idhash;

open(INL, $inputlist) || die "cannot open $!";
while(<INL>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $idseq1 = $F[6];
  my $idseq2 = $F[7];

  my $idseq = $idseq1.",".$idseq2;
  my @idseqar = split(",", $idseq);
  
  for (my $i = 0; $i <= $#idseqar; $i++) {
    if ($i % 2 == 0) {
      $idhash{$idseqar[$i]} = 1;
    }
  }
}
close(INL);

open(INSAM, $inputsam) || die "cannot open $!";
while(<INSAM>) {

  s/[\r\n]//g;
  next if ($_ =~ /^@/);
  
  my @F = split("\t", $_);
  my $line = $_;
  my $qname = $F[0];
  
  next if (not exists $idhash{$qname});
  print $line ."\n";

}
close(INSAM);

