#! /usr/loca/bin/perl

use strict;
use warnings;

my $idseq = $ARGV[0];
my $inputsam = $ARGV[1];
my $outputfa = $ARGV[2];

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

open(OUTFA, ">" . $outputfa) || die "cannot open $!";
open(INSAM, $inputsam) || die "cannot open $!";
while(<INSAM>) {
  s/[\r\n]//g;
  
  next if ($_ =~ /^@/);

  my @F = split("\t", $_);
  my $qname = $F[0];
  next if (not exists $idhash{$qname});
  my $flag = $F[1];
  my $seq = $F[9];

  my $flag2val = sprintf "%b", $flag;
  my $flag2len = length($flag2val);
  my $firstpair = substr($flag2val,($flag2len-7),1);
  my $secondpair = substr($flag2val,($flag2len-8),1);

  if ($firstpair == 1) {
    print OUTFA  ">".$qname."#1\n";
    print OUTFA  $seq."\n";
  }
  elsif ($secondpair == 1) {
    print OUTFA  ">".$qname."#2\n";
    print OUTFA  $seq."\n";
  }
  else {
    print "unsupported flag : " .$flag. "\n";
    exit 1;
  }  
}
close(INSAM);
close(OUTFA);

