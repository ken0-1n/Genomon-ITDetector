#! /usr/local/bin/perl

use strict;

my $inputlist = $ARGV[0];
my $inputbed = $ARGV[1];

my %junc2Keys = ();
  
open(IN, $inputbed) || die "cannot open $inputbed";
while(<IN>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  my $sample = $F[8];

  $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
  my $pos11 = $3;
  my $pos12 = $6;

  $F[4] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
  my $pos21 = $3;
  my $pos22 = $6;

  if (abs($pos11 - $pos21) <= 10 and abs($pos12 - $pos22) <= 10) {
    my $key = $F[3]."\t".$F[4];
    # print "key=".$key."\n";
    
    if (exists $junc2Keys{$key}) {
      my $vals = $junc2Keys{$key};
      my @valsArr = split(";", $vals);
    
      next if ($#valsArr >= 20); 
      my $check = 0;
      foreach my $val (@valsArr) {
        if ($val eq $sample) {
          $check = 1;
          last;
        }
      }
      if ( $check == 0){
        $junc2Keys{$key} = $vals .";".$sample;
      }
    }
    else {
      $junc2Keys{$key} = $sample;
    }
  }
} 
close(IN);

open(INL, $inputlist) || die "cannot open $inputlist";
while(<INL>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_;
  my $keyl = $F[0]."\t".$F[3];

  if (exists $junc2Keys{$keyl}) {
    my $val = $junc2Keys{$keyl};
    print join("\t", @F[0 .. 23]) ."\t". $val ."\t". $F[24] ."\n";
  }
  else {
    print join("\t", @F[0 .. 23]) ."\t".  "\t", $F[24] ."\n";
  }
}
close(INL);
