#! /usr/local/bin/perl

use strict;

my $inputlist = $ARGV[0];
my $input = $ARGV[1];
my $sample_args = $ARGV[2];

my %inhouseLeft = ();
my %inhouseRight = ();

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    
    my $keyl = $F[0]."\t".$F[1]."\t".$F[2];
    my $keyr = $F[4]."\t".$F[5]."\t".$F[6];
    my $sample = $F[8];
    my $support = $F[9];

    if ($sample ne $sample_args) { 
        if (exists $inhouseLeft{$keyl}) {
            my $ssVal = $inhouseLeft{$keyl};
            $inhouseLeft{$keyl} = $ssVal.";".$sample.$support;
        }
        else {
            $inhouseLeft{$keyl} = $sample.$support;
        }
        if (exists $inhouseRight{$keyr}) {
            my $ssVal = $inhouseRight{$keyr};
            $inhouseRight{$keyr} = $ssVal.";".$sample.$support;
        }
        else {
            $inhouseRight{$keyr} = $sample.$support;
        }
    }
}
close(IN);

open(INL, $inputlist) || die "cannot open $inputlist";
while(<INL>) {

  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_;
  
  $F[2] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
  my $lchr1 = $1;
  my $lbp1 = $3;
  my $lbp2 = $6;
  $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
  my $rchr1 = $1;
  my $rbp1 = $3;
  my $rbp2 = $6;

  my $keyl = $lchr1 ."\t". $lbp1 ."\t". $lbp2;
  my $keyr = $rchr1 ."\t". $rbp1 ."\t". $rbp2;

  if (exists $inhouseLeft{$keyl}) {
      my $val = $inhouseLeft{$keyl};
      my @ssVals = split(";", $val);
      my %inhouseLeft_sort = ();
      foreach my $ssVal (@ssVals) {
          $inhouseLeft_sort{$ssVal} = 1;
          my $cnt = scalar(keys(%inhouseLeft_sort));
          last if ($cnt >= 20);
      }
      my $res = "";
      foreach my $tmpres (keys %inhouseLeft_sort) {
          $res = $res.";".$tmpres;
      }
      print join("\t", @F[0 .. 30]) ."\t". substr($res,1) ."\t". $F[31] ."\n";
  }
  elsif (exists $inhouseRight{$keyr}) {
      my $val = $inhouseRight{$keyr};
      my @ssVals = split(";", $val);
      my %inhouseRight_sort = ();
      foreach my $ssVal (@ssVals) {
          $inhouseRight_sort{$ssVal} = 1;
          my $cnt = scalar(keys(%inhouseRight_sort));
          last if ($cnt >= 20);
      }
      my $res = "";
      foreach my $tmpres (keys %inhouseRight_sort) {
          $res = $res.";".$tmpres;
      } 
      print join("\t", @F[0 .. 30]) ."\t". substr($res,1) ."\t". $F[31] ."\n";
  }
  else {
      print join("\t", @F[0 .. 30]) ."\t".  "\t", $F[31] ."\n";
  }
}
close(INL);
