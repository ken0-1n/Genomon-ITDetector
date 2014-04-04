#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];
my $nc = 24; # number of cncatenation 

open(IN, $input) || die "cannot open $!";
my $cnt = 1;
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    
    next if (not $F[0] =~ /(\w+):([\+\-])(\d+)/);

    $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr11 = $1;
    my $pos11 = $3;
    my $chr12 = $4;
    my $pos12 = $6;

    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr21 = $1;
    my $pos21 = $3;
    my $chr22 = $4;
    my $pos22 = $6;
      
    my $spos1 = $pos12 - 1;
    my $epos1 = $pos11;
    my $spos2 = $pos21 - 1;
    my $epos2 = $pos22;

    next if ($spos1 < $nc or $spos2 < $nc);

    print $chr11 ."\t". ($spos1 - $nc) ."\t".  $spos1        ."\t". $cnt. "_pdn1_left\n";
    print $chr11 ."\t".  $spos1        ."\t".  $epos1        ."\t". $cnt. "_pdn1\n";
    print $chr11 ."\t".  $epos1        ."\t". ($epos1 + $nc) ."\t". $cnt. "_pdn1_right\n";
    print $chr11 ."\t". ($spos2 - $nc) ."\t".  $spos2        ."\t". $cnt. "_pdn2_left\n";
    print $chr11 ."\t".  $spos2        ."\t".  $epos2        ."\t". $cnt. "_pdn2\n";
    print $chr11 ."\t".  $epos2        ."\t". ($epos2 + $nc) ."\t". $cnt. "_pdn2_right\n";
    
    $cnt++;
}
close(IN);

