#! /usr/local/bin/perl

use strict;
use warnings;

my $input1 = $ARGV[0];
my $input2 = $ARGV[1];
my $ad_range = $ARGV[2];

sub getJuncKeys {
  my $filename = $_[0];
  my %junc2Keys = ();
  
  open(IN, $filename) || die "cannot open $filename";
  while(<IN>) {

    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $num11 = $F[4];
    my $num12 = $F[5];
    my $idseq1 = $F[6];
    my $num21 = $F[11];
    my $num22 = $F[12];
    my $idseq2 = $F[13];

    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr11 = $1;
    my $strand11 = $2 eq "+" ? 1 : -1;
    my $pos11 = $3;
    my $chr12 = $4;
    my $strand12 = $5 eq "+" ? 1 : -1;
    my $pos12 = $6;
    my $clip1 = $7;

    $F[10] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr21 = $1;
    my $strand21 = $2 eq "+" ? 1 : -1;
    my $pos21 = $3;
    my $chr22 = $4;
    my $strand22 = $5 eq "+" ? 1 : -1;
    my $pos22 = $6;
    my $clip2 = $7;

    if (abs($pos11 - $pos22) <= 10 and abs($pos21 - $pos12) <= 10) {
      my $val1 = $F[3] ."\t". $num11 ."\t". $num12;
      my $val2 = $F[10] ."\t". $num21 ."\t". $num22;
      my $val = $val1 ."\t". $val2;
      $junc2Keys{join("\t", sort ($val1, $val2))} = $idseq1 ."\t". $idseq2 ."\t". $ad_range;
    }
  }
  close(IN);
  return %junc2Keys;
}

my %junc2Keys1 = &getJuncKeys($input1);
my %junc2Keys2 = &getJuncKeys($input2);

foreach my $key (sort keys %junc2Keys1) {
    if ( exists($junc2Keys2{$key}) ) {
      print $key ."\t". $junc2Keys2{$key} ."\n";
    }
}

