#! /usr/local/bin/perl

use strict;

my $input_itdlist = $ARGV[0];
my $input_inhouse = $ARGV[1];

my %inhouse_hash = ();
open(IN, $input_inhouse) || die "cannot open $input_inhouse";
while(<IN>) {
  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $chr  = $F[0];
  my $pos1 = $F[1];
  my $pos2 = $F[2];
  my $sample_support = $F[3];

  my $key = $chr ."\t". $pos1 ."\t". $pos2;

  $inhouse_hash{$key} = $inhouse_hash{$key} .";". $sample_support;

}
close(IN);

if (keys(%inhouse_hash) < 1) {
  exit 0;
}

open(IN, $input_itdlist) || die "cannot open $input_itdlist";
while(<IN>) {
  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $chr  = $F[0];
  my $pos1 = $F[1];
  my $pos2 = $F[2];
  my $linekey1 = $F[3];
  my $linekey2 = $F[4];

  my $print_inhouse_data = "";
  foreach my $inhouse_keys (keys %inhouse_hash) {
    my @ik_arr = split("\t", $inhouse_keys);
    my $ichr  = $ik_arr[0];
    my $ipos1 = $ik_arr[1];
    my $ipos2 = $ik_arr[2];

    # if (($chr eq $ichr) and (abs(($pos1 - $ipos1)) <= 5) and (abs(($pos2 - $ipos2)) <= 5)) {
    if (($chr eq $ichr) and (abs(($pos1 - $ipos1)) == 0) and (abs(($pos2 - $ipos2)) == 0)) {
      $print_inhouse_data = $print_inhouse_data.$inhouse_hash{$inhouse_keys} 
    }
  }

  # put sortHash
  $print_inhouse_data = substr($print_inhouse_data,1); 
  my @valsArr = split(";", $print_inhouse_data);
  my %sortHash = ();
  foreach my $val (@valsArr) {
    $sortHash{$val} = 1; 
  }

  my $cnt = 1;
  $print_inhouse_data = "";
  foreach my $key (sort keys %sortHash) {
    $print_inhouse_data = $print_inhouse_data.";".$key;
    last if ($cnt >= 20);
    $cnt++;
  }
  $print_inhouse_data = substr($print_inhouse_data,1); 
  print $linekey1 ."\t". $linekey2 ."\t". $print_inhouse_data ."\n";

}
close(IN);

