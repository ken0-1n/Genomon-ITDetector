#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];

my %hash;
open(IN, $input) || die "cannot open $!";
while(<IN>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $junc1 = $F[0];
  my $junc2 = $F[3];
  my $line = $_;
   
  if (not exists $hash{$junc1}) {
    my @array;
    @{$hash{$junc1}} = @array;
    push (@{$hash{$junc1}}, $line);
  }
  else {
    push (@{$hash{$junc1}}, $line);
  }
}

while (my ($aaa, $bbb) = each(%hash)) {

  if (2 <= @{$bbb}) {
    my $printNo = 0;
    my $printNoNum = 0;
    my $i = 0;
    foreach (@{$bbb}) {
      my @F = split("\t", $_);
      my $sclipNum = ($F[4] + $F[5]);
      if ($sclipNum > $printNoNum) {
        $printNo = $i;
        $printNoNum = $sclipNum;
      }
      $i++;
    }
    $i = 0;
    foreach (@{$bbb}) {
      my @F = split("\t", $_);
      my $sclipNum = ($F[4] + $F[5]);
      if ($printNo == $i) {
        print $_ . "\n";
      }
      $i++;
    }
  }
  else {
    foreach (@{$bbb}) {
    print $_ . "\n";
    }
  }
}
close(IN);

