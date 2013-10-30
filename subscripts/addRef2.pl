#! /usr/loca/bin/perl

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];
my $input_fasta = $ARGV[1];
my $output = $ARGV[2];

my %fastahash = ();
open(IN_FA, $input_fasta) || die "cannot open $!";

while(<IN_FA>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $fastahash{$F[0]} = $F[1];
}
close(IN_FA);

open(IN, $input) || die "cannot open $!";
open(OUT, ">" . $output) || die "cannot open $!";
my $cnt = 1;
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $line = $_;
    
    next if (not $F[0] =~ /(\w+):([\+\-])(\d+)/);

    print OUT $line ."\t";
    print OUT $fastahash{$cnt."_1_itd"}."\t";
    print OUT $fastahash{$cnt."_2_itd"}."\t";
    print OUT substr($fastahash{$cnt."_2_seq"},-24)."\t";
    print OUT substr($fastahash{$cnt."_1_seq"},0,24)."\t";
    print OUT $fastahash{$cnt."_2_seq"}."\t";
    print OUT $fastahash{$cnt."_1_seq"}."\t";
    print OUT $fastahash{$cnt."_itd"}."\n";
    $cnt++;
}
close(IN);
close(OUT);

