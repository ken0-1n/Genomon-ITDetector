#! /usr/local/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my $thres_ambiguity_range = $ARGV[1];
my $thres_support_reads = $ARGV[2];

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

    if((not defined $num11) or (not defined $num12) or (not defined $num21) or (not defined $num22)) {
      print STDERR "not defined error: num11 num12 num21 num22 \n";
      exit 1;
    }

    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr11 = $1;
    my $pos11 = $3;
    my $chr12 = $4;
    my $pos12 = $6;

    $F[10] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr21 = $1;
    my $pos21 = $3;
    my $chr22 = $4;
    my $pos22 = $6;


    my $support_read_pdn1 = ($num11 + $num12);
    my $support_read_pdn2 = ($num21 + $num22);
    next if ($support_read_pdn1 < $thres_support_reads and $support_read_pdn2 < $thres_support_reads);
  
    next if (abs($pos11 - $pos22) > $thres_ambiguity_range or abs($pos12 - $pos21) > $thres_ambiguity_range);
   
    my $val1 = $F[3]  ."\t". $num11 ."\t". $num12;
    my $val2 = $F[10] ."\t". $num21 ."\t". $num22;
    $junc2Keys{join("\t", sort ($val1, $val2))} = $idseq1 ."\t". $idseq2;

  }
  close(IN);
  return %junc2Keys;
}

my %junc2Keys = &getJuncKeys($input);

foreach my $key (sort keys %junc2Keys) {
  print $key ."\t". $junc2Keys{$key} ."\n";
}

