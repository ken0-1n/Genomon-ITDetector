#! /usr/local/bin/perl

use strict;

my $inputlist = $ARGV[0];
my $inputinhouse = $ARGV[1];
my $sample_args = $ARGV[2];

my %inhouseLeft = ();
my %inhouseRight = ();

open(IN, $inputinhouse) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    
    my $keyl = $F[0]."\t".$F[1]."\t".$F[2]; # chr:-pos+pos
    my $keyr = $F[4]."\t".$F[5]."\t".$F[6]; # chr:+pos-pos
    my $sample = $F[8];
    my $support = $F[9];
  
    my $supporttmp = $support;
    $supporttmp =~ s/\(//g;
    $supporttmp =~ s/\)//g;
    my @stArr = split(",", $supporttmp); 
    my $leftCount  = $stArr[0] + $stArr[1];
    my $rightCount = $stArr[2] + $stArr[3];

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
  
  my $print_inhouse_data = "";
  my $LR = $F[18];

  if ($LR =~ /1/ ) {
    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    my $chr = $1;
    my $bp1 = $3;
    my $bp2 = $6;

    foreach my $inhouse_keys (keys %inhouseLeft) {
      my @ik_arr = split("\t", $inhouse_keys);
      my $ichr = $ik_arr[0];
      my $ibp1 = $ik_arr[1];
      my $ibp2 = $ik_arr[2];
      if ($chr eq $ichr and (abs(($bp1 - $ibp1)) <= 5) and (abs(($bp2 - $ibp2)) <= 5)) {
      # if ($chr eq $ichr and (abs(($bp1 - $ibp1)) == 0) and (abs(($bp2 - $ibp2)) == 0)) {
        $print_inhouse_data = $print_inhouse_data.";".$inhouseLeft{$inhouse_keys}; 
      }
    }
  }
  elsif ($LR == 2) {

    $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    my $chr = $1;
    my $bp1 = $3;
    my $bp2 = $6;
  
    foreach my $inhouse_keys (keys %inhouseRight) {
      my @ik_arr = split("\t", $inhouse_keys);
      my $ichr = $ik_arr[0];
      my $ibp1 = $ik_arr[1];
      my $ibp2 = $ik_arr[2];
      if ($chr eq $ichr and (abs(($bp1 - $ibp1)) <= 5) and (abs(($bp2 - $ibp2)) <= 5)) {
      # if ($chr eq $ichr and (abs(($bp1 - $ibp1)) == 0) and (abs(($bp2 - $ibp2)) == 0)) {
        $print_inhouse_data = $print_inhouse_data.";".$inhouseRight{$inhouse_keys}; 
      }
    }
  }

  if ($print_inhouse_data ne "") {
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
    print join("\t", @F[0 .. 30]) ."\t". $print_inhouse_data ."\t". $F[31] ."\n";
  }
  else {
    print join("\t", @F[0 .. 30]) ."\t".                      "\t". $F[31] ."\n";
  }
}
close(INL);

