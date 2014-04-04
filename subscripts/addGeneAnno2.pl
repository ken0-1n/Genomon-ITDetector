#! /usr/loca/bin/perl

use strict;
use List::Util qw(max);

my $input = $ARGV[0];
my $ref_ce_file = $ARGV[1];
my $ref_ci_file = $ARGV[2];
my $ref_c5_file = $ARGV[3];
my $ref_c3_file = $ARGV[4];
my $ref_ne_file = $ARGV[5];
my $ref_ni_file = $ARGV[6];
my $annoensfile = $ARGV[7];
my $annoknownfile = $ARGV[8];
my $annorepeatfile = $ARGV[9];

my %ref_ce_hash = ();
open(ANNO, $ref_ce_file) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $ref_ce_hash{$key} = $F[3];
}
close(ANNO);

my %ref_ci_hash = ();
open(ANNO, $ref_ci_file) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $ref_ci_hash{$key} = $F[3];
}
close(ANNO);

my %ref_c5_hash = ();
open(ANNO, $ref_c5_file) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $ref_c5_hash{$key} = $F[3];
}
close(ANNO);

my %ref_c3_hash = ();
open(ANNO, $ref_c3_file) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $ref_c3_hash{$key} = $F[3];
}
close(ANNO);

my %ref_ne_hash = ();
open(ANNO, $ref_ne_file) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $ref_ne_hash{$key} = $F[3];
}
close(ANNO);

my %ref_ni_hash = ();
open(ANNO, $ref_ni_file) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $ref_ni_hash{$key} = $F[3];
}
close(ANNO);

my %enshash = ();
open(ANNO, $annoensfile) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $enshash{$key} = $F[3];
}
close(ANNO);

my %knownhash = ();
open(ANNO, $annoknownfile) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $knownhash{$key} = $F[3];
}
close(ANNO);

my %repeathash = ();
open(ANNO, $annorepeatfile) || die "cannot open $!";
while(<ANNO>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = $F[0]."\t".$F[1]."\t".$F[2];
  $repeathash{$key} = $F[3];
}
close(ANNO);

open(IN, $input) || die "cannot open $!";
while(<IN>) {
  
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_;

  # my $chr = $F[7];
  # my $start = $F[8];
  # my $end = $F[9];

  $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
  my $chr1 = $1;
  my $pos11 = $3;
  my $pos12 = $6;
  # my $pos12 = $6 - 1;
    
  $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
  my $chr2 = $1;
  # my $pos21 = $3 - 1;
  my $pos21 = $3;
  my $pos22 = $6;
     
  my @pos1Array = ($pos11,$pos22);
  my @pos2Array = ($pos12,$pos21);
  my $chr = $chr2;
  my $start = getmin(@pos2Array);
  my $end = getmax(@pos1Array);
    
  my $ref_ce_val = "";
  foreach my $ref_ce_key (keys(%ref_ce_hash)) {
    my @ref_ce_keys = split("\t", $ref_ce_key);
    if(($ref_ce_keys[0] eq $chr) and
      (($ref_ce_keys[1] <= $start and $start <= $ref_ce_keys[2]) or ($ref_ce_keys[1] <= $end and $end <= $ref_ce_keys[2]) or ($start <= $ref_ce_keys[1] and $ref_ce_keys[2] <= $end))) {
      $ref_ce_val = $ref_ce_val.";".$ref_ce_hash{$ref_ce_key};
    }
  }
  if (length($ref_ce_val) > 0) { 
    $ref_ce_val = substr($ref_ce_val,1,(length($ref_ce_val)-1));
  }
  my $ref_ci_val = "";
  foreach my $ref_ci_key (keys(%ref_ci_hash)) {
    my @ref_ci_keys = split("\t", $ref_ci_key);
    if(($ref_ci_keys[0] eq $chr) and
      (($ref_ci_keys[1] <= $start and $start <= $ref_ci_keys[2]) or ($ref_ci_keys[1] <= $end and $end <= $ref_ci_keys[2]) or ($start <= $ref_ci_keys[1] and $ref_ci_keys[2] <= $end))) {
      $ref_ci_val = $ref_ci_val.";".$ref_ci_hash{$ref_ci_key};
    }
  }
  if (length($ref_ci_val) > 0) { 
    $ref_ci_val = substr($ref_ci_val,1,(length($ref_ci_val)-1));
  }
  my $ref_c5_val = "";
  foreach my $ref_c5_key (keys(%ref_c5_hash)) {
    my @ref_c5_keys = split("\t", $ref_c5_key);
    if(($ref_c5_keys[0] eq $chr) and
      (($ref_c5_keys[1] <= $start and $start <= $ref_c5_keys[2]) or ($ref_c5_keys[1] <= $end and $end <= $ref_c5_keys[2]) or ($start <= $ref_c5_keys[1] and $ref_c5_keys[2] <= $end))) {
      $ref_c5_val = $ref_c5_val.";".$ref_c5_hash{$ref_c5_key};
    }
  }
  if (length($ref_c5_val) > 0) { 
    $ref_c5_val = substr($ref_c5_val,1,(length($ref_c5_val)-1));
  } 
  my $ref_c3_val = "";
  foreach my $ref_c3_key (keys(%ref_c3_hash)) {
    my @ref_c3_keys = split("\t", $ref_c3_key);
    if(($ref_c3_keys[0] eq $chr) and
      (($ref_c3_keys[1] <= $start and $start <= $ref_c3_keys[2]) or ($ref_c3_keys[1] <= $end and $end <= $ref_c3_keys[2]) or ($start <= $ref_c3_keys[1] and $ref_c3_keys[2] <= $end))) {
      $ref_c3_val = $ref_c3_val.";".$ref_c3_hash{$ref_c3_key};
    }
  }
  if (length($ref_c3_val) > 0) { 
    $ref_c3_val = substr($ref_c3_val,1,(length($ref_c3_val)-1));
  } 
  my $ref_ne_val = "";
  foreach my $ref_ne_key (keys(%ref_ne_hash)) {
    my @ref_ne_keys = split("\t", $ref_ne_key);
    if(($ref_ne_keys[0] eq $chr) and
      (($ref_ne_keys[1] <= $start and $start <= $ref_ne_keys[2]) or ($ref_ne_keys[1] <= $end and $end <= $ref_ne_keys[2]) or ($start <= $ref_ne_keys[1] and $ref_ne_keys[2] <= $end))) {
      $ref_ne_val = $ref_ne_val.";".$ref_ne_hash{$ref_ne_key};
    }
  }
  if (length($ref_ne_val) > 0) { 
    $ref_ne_val = substr($ref_ne_val,1,(length($ref_ne_val)-1));
  } 
  my $ref_ni_val = "";
  foreach my $ref_ni_key (keys(%ref_ni_hash)) {
    my @ref_ni_keys = split("\t", $ref_ni_key);
    if(($ref_ni_keys[0] eq $chr) and
      (($ref_ni_keys[1] <= $start and $start <= $ref_ni_keys[2]) or ($ref_ni_keys[1] <= $end and $end <= $ref_ni_keys[2]) or ($start <= $ref_ni_keys[1] and $ref_ni_keys[2] <= $end))) {
      $ref_ni_val = $ref_ni_val.";".$ref_ni_hash{$ref_ni_key};
    }
  }
  if (length($ref_ni_val) > 0) { 
    $ref_ni_val = substr($ref_ni_val,1,(length($ref_ni_val)-1));
  } 
  my $ensval = "";
  foreach my $enskey (keys(%enshash)) {
    my @enskeys = split("\t", $enskey);
    if(($enskeys[0] eq $chr) and
      (($enskeys[1] <= $start and $start <= $enskeys[2]) or ($enskeys[1] <= $end and $end <= $enskeys[2]) or ($start <= $enskeys[1] and $enskeys[2] <= $end))) {
      $ensval = $ensval.";".$enshash{$enskey};
    }
  }
  if (length($ensval) > 0) { 
    $ensval = substr($ensval,1,(length($ensval)-1));
  }
  my $knownval = "";
  foreach my $knownkey (keys(%knownhash)) {
    my @knownkeys = split("\t", $knownkey);
    if (($knownkeys[0] eq $chr) and
       (($knownkeys[1] <= $start and $start <= $knownkeys[2]) or ($knownkeys[1] <= $end and $end <= $knownkeys[2]) or ($start <= $knownkeys[1] and $knownkeys[2] <= $end))) {
      $knownval = $knownval.";".$knownhash{$knownkey};
    }
  }
  if (length($knownval) > 0) { 
    $knownval = substr($knownval,1,(length($knownval)-1));
  } 
  my $repeatval = "";
  foreach my $repeatkey (keys(%repeathash)) {
    my @repeatkeys = split("\t", $repeatkey);
    if(($repeatkeys[0] eq $chr) and
      (($repeatkeys[1] <= $start and $start <= $repeatkeys[2]) or ($repeatkeys[1] <= $end and $end <= $repeatkeys[2]) or ($start <= $repeatkeys[1] and $repeatkeys[2] <= $end))) {
      $repeatval = $repeatval.";".$repeathash{$repeatkey};
    }
  }
  if (length($repeatval) > 0) { 
    $repeatval = substr($repeatval,1,(length($repeatval)-1));
  } 
  print join("\t", @F[0 .. 21]) ."\t";
  print $ref_ce_val ."\t". $ref_ci_val ."\t". $ref_c5_val ."\t". $ref_c3_val ."\t". $ref_ne_val ."\t". $ref_ni_val."\t". $ensval."\t".$knownval. "\t".$repeatval ."\t";
  print $F[22] ."\n";
}
close(IN);

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



