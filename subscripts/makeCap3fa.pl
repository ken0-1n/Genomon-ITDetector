#! /usr/loca/bin/perl

use strict;
use warnings;

my $idseq = $ARGV[0];
my $inputsam = $ARGV[1];

my %idhash;
open(IDSEQ, $idseq) || die "cannot open $!";
while(<IDSEQ>) {
  s/[\r\n]//g;
  my @idseqar = split(",", $_);
  for (my $i = 0; $i <= $#idseqar; $i++) {
    if ($i % 2 == 0) {
      $idhash{$idseqar[$i]} = 1;
    }
  }
}
close(IDSEQ);

open(INSAM, $inputsam) || die "cannot open $!";
while(<INSAM>) {
  s/[\r\n]//g;
  
  next if ($_ =~ /^@/);

  my @F = split("\t", $_);
  my $qname = $F[0];
  next if (not exists $idhash{$qname});
  my @flags = split("", sprintf("%012b", $F[1]));
  my $first_in_pair = $flags[5];
  my $second_in_pair = $flags[4];
  my $read_revers_strand = $flags[7];
  my $seq = $read_revers_strand == 1 ? &complementSeq($F[9]) : $F[9];

  if ($first_in_pair == 1) {
    print ">".$qname."#1\n";
    print $seq."\n";
  }
  elsif ($second_in_pair == 1) {
    print ">".$qname."#2\n";
    print $seq."\n";
  }
  else {
    print STDERR "unsupported flag : " .$F[1]. "\n";
    exit 1;
  }  
}
close(INSAM);

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

