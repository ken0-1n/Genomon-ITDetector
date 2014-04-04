#! /usr/local/bin/perl

use strict;

my $inputlist = $ARGV[0];
my $input_left_bed = $ARGV[1];
my $input_right_bed = $ARGV[2];

my %junc2KeysLeft = ();
open(IN1, $input_left_bed) || die "cannot open $input_left_bed";
while(<IN1>) {

  s/[\r\n]//g;
  my @F = split("\t", $_);

  my $sample = $F[2];
  my $key = $F[0]."\t".$F[1];
    
  $junc2KeysLeft{$key} = $sample;
} 
close(IN1);

my %junc2KeysRight = ();
open(IN2, $input_right_bed) || die "cannot open $input_right_bed";
while(<IN2>) {

  s/[\r\n]//g;
  my @F = split("\t", $_);

  my $sample = $F[2];
  my $key = $F[0]."\t".$F[1];
    
  $junc2KeysRight{$key} = $sample;
} 
close(IN2);

open(INL, $inputlist) || die "cannot open $inputlist";
while(<INL>) {
  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[3];
  my $val = "";

  if (exists $junc2KeysLeft{$key} and exists $junc2KeysRight{$key}) {
    $val = $junc2KeysLeft{$key} ."\t". $junc2KeysRight{$key};
  }
  elsif (exists $junc2KeysRight{$key}) {
    $val = $junc2KeysLeft{$key}. "\t";
  }
  elsif (exists $junc2KeysLeft{$key}) {
    $val = "\t". $junc2KeysRight{$key};
  }
  else {
    $val = "\t";
  }
  print join("\t", @F[0 .. 31]) ."\t". $val ."\t". $F[32] ."\n";
}
close(INL);

