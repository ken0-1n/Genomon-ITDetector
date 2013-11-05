#! /usr/local/bin/perl

use strict;

my $inputlist = $ARGV[0];
my $input1bed = $ARGV[1];
my $input2bed = $ARGV[2];

my %junc2Keys1 = ();
open(IN1, $input1bed) || die "cannot open $input1bed";
while(<IN1>) {

  s/[\r\n]//g;
  my @F = split("\t", $_);

  my $sample = $F[2];
  my $key = $F[0]."\t".$F[1];
    
  if (exists $junc2Keys1{$key}) {
    my $vals = $junc2Keys1{$key};
    my @valsArr = split(";", $vals);
    
    next if (@valsArr >= 20); 
    my $check = 0;
    foreach my $val (@valsArr) {
      if ($val eq $sample) {
        $check = 1;
        last;
      }
    }
    if ( $check == 0){
      $junc2Keys1{$key} = $vals .";".$sample;
    }
  }
  else {
    $junc2Keys1{$key} = $sample;
  }
} 
close(IN1);

my %junc2Keys2 = ();
open(IN2, $input2bed) || die "cannot open $input2bed";
while(<IN2>) {

  s/[\r\n]//g;
  my @F = split("\t", $_);

  my $sample = $F[2];
  my $key = $F[0]."\t".$F[1];
    
  if (exists $junc2Keys2{$key}) {
    my $vals = $junc2Keys2{$key};
    my @valsArr = split(";", $vals);
     
    next if (@valsArr >= 20); 
    my $check = 0;
    foreach my $val (@valsArr) {
      if ($val eq $sample) {
        $check = 1;
        last;
      }
    }
    if ( $check == 0){
      $junc2Keys2{$key} = $vals .";".$sample;
    }
  }
  else {
    $junc2Keys2{$key} = $sample;
  }
} 
close(IN2);

open(INL, $inputlist) || die "cannot open $inputlist";
while(<INL>) {
  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $line = $_;
  my $keyl = $F[0]."\t".$F[3];
  my $val = "";

  if (exists $junc2Keys1{$keyl} and exists $junc2Keys2{$keyl}) {
    $val = $junc2Keys2{$keyl} ."\t". $junc2Keys1{$keyl};
  }
  elsif (exists $junc2Keys2{$keyl}) {
    $val = $junc2Keys2{$keyl}. "\t";
  }
  elsif (exists $junc2Keys1{$keyl}) {
    $val = "\t". $junc2Keys1{$keyl};
  }
  else {
    $val = "\t";
  }
  print join("\t", @F[0 .. 31]) ."\t". $val ."\t". $F[32] ."\n";
}
close(INL);

