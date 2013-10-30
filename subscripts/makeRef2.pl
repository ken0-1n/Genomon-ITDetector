#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];
my $output = $ARGV[1];

open(IN, $input) || die "cannot open $!";
open(OUT, ">" . $output) || die "cannot open $!";
my $cnt = 1;
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    
    next if (not $F[0] =~ /(\w+):([\+\-])(\d+)/);

    $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr11 = $1;
    my $pos11 = $3 ;
    my $strand11 = $2;
    my $chr12 = $4;
    my $pos12 = $6;
    my $strand12 = $5;
    my $clip1 = $7;
    my $cliplen1 = length($clip1);

    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr21 = $1;
    my $pos21 = $3;
    my $strand21 = $2;
    my $chr22 = $4;
    my $pos22 = $6;
    my $strand22 = $5;
    my $clip2 = $7;
    my $cliplen2 = length($clip2);
      
    my @posArray1 = ($pos11,$pos12);
    my @posArray2 = ($pos21,$pos22);
    my $spos1 = getmin(@posArray1);
    my $epos1 = getmax(@posArray1);
    my $spos2 = getmin(@posArray2);
    my $epos2 = getmax(@posArray2);

    my $checkzero1 = 0;
    my $checkzero2 = 0;
    if ($F[1] == 0 or $F[2] == 0) {
      $checkzero1 = 1;
    } elsif ($F[4] == 0 or $F[5] == 0) {
      $checkzero2 = 1;
    }
    
    my $juncCount1 = ($F[1] + $F[2]);
    my $juncCount2 = ($F[4] + $F[5]);

    my $spos = 0;
    my $epos = 0;
    if (($checkzero1 == 0) and ($checkzero2 == 1)) {
      $spos = $spos1;
      $epos = $epos1;
    }
    elsif (($checkzero1 == 1) and ($checkzero2 == 0)) {
      $spos = $spos2;
      $epos = $epos2;
    }
    else {
      if ($juncCount1 > $juncCount2) {
        $spos = $spos1;
        $epos = $epos1;
      } else {
        $spos = $spos2;
        $epos = $epos2;
      }
    }
    print OUT $chr11."\t".($spos1 - 1) ."\t".$epos1 ."\t".$cnt."_1_itd\n";
    print OUT $chr21."\t".($spos2 - 1) ."\t".$epos2 ."\t".$cnt."_2_itd\n";
    
    print OUT $chr21."\t".($spos - 1) ."\t".$epos ."\t".$cnt."_itd\n";
    print OUT $chr21."\t".($epos) ."\t".($epos + 200)."\t".$cnt."_1_seq\n";
    if ($spos > 201) {
        print OUT $chr21."\t".($spos - 201)."\t".($spos - 1)."\t".$cnt."_2_seq\n";
    }
    else {
        print OUT $chr21."\t". "0" ."\t".($spos - 1)."\t".$cnt."_2_seq\n";
    }
    $cnt++;
}
close(IN);
close(OUT);

sub getmin {
  my $min = shift;
  foreach(@_){
    $min = $_ if( $min > $_ );
  }
  return( $min );
}

sub getmax {
  my $max = shift;
  foreach(@_){
    $max = $_ if( $max < $_ );
  }
  return( $max );
}

