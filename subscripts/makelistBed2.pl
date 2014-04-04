#! /usr/local/bin/perl

use strict;

my $input_list = $ARGV[0];
my $output_left_list = $ARGV[1];
my $output_right_list = $ARGV[2];

open(OUT_LEFT, ">".$output_left_list) || die "cannot open $!";
open(OUT_RIGHT, ">".$output_right_list) || die "cannot open $!";
open(INL, $input_list) || die "cannot open $!";
while(<INL>) {

    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $key = $F[0]."\t".$F[3];
      
    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    my $lchr1 = $1;
    my $lbp1 = $3;
    my $lchr2 = $4;
    my $lbp2 = $6;
    $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    my $rchr1 = $1;
    my $rbp1 = $3;
    my $rchr2 = $4;
    my $rbp2 = $6;
   
    if ($lbp1 > 0 and $lbp2 > 0) {
      print OUT_LEFT  $lchr1 ."\t". $lbp1 ."\t". $lbp2 ."\t". $key . "\n"; 
    }
    if ($rbp2 > 0 and $rbp2 > 0) {
      print OUT_RIGHT $rchr1 ."\t". $rbp1 ."\t". $rbp2 ."\t". $key . "\n"; 
    }
}
close(INL);
close(OUT_LEFT);
close(OUT_RIGHT);

