#! /usr/loca/bin/perl

use strict;
use warnings;

my $input = $ARGV[0];
my $input_fasta = $ARGV[1];
my $nc = 24; # number of cncatenation 

my %fastahash = ();
open(IN_FA, $input_fasta) || die "cannot open $!";

while(<IN_FA>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $fastahash{$F[0]} = $F[1];
}
close(IN_FA);

open(IN, $input) || die "cannot open $!";
my $cnt = 1;
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $line = $_;
    
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

    print $line ."\t";
    print $fastahash{$cnt."_pdn1_left"}."\t";
    print $fastahash{$cnt."_pdn1"}."\t";
    print $fastahash{$cnt."_pdn1_right"}."\t";
    print $fastahash{$cnt."_pdn2_left"}."\t";
    print $fastahash{$cnt."_pdn2"}."\t";
    print $fastahash{$cnt."_pdn2_right"}."\n";
    $cnt++;
}
close(IN);

