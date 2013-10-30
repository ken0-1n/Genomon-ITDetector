#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input_list = $ARGV[0];

open(IN_LIST, $input_list) || die "cannot open $!";
while(<IN_LIST>) {
    s/[\r\n]//g;
    my $line = $_;
    my @F = split("\t", $_);
    my $selection_code = $F[17];

    my $chr = "";
    my $start = 0;
    my $end = 0;
   
    if ($selection_code == 1) {
      $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
      $chr = $1;
      $end = $3;
      $start = $6;
    }
    else {
      $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
      $chr = $1;
      $start = $3;
      $end = $6;
    }
    
    print $chr."\t".$start."\t".$end."\t".$line."\n";
}
close(IN_LIST);

