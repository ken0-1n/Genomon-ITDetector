#! /usr/local/bin/perl

use strict;
use List::Util qw(max), qw(min);

my $input = $ARGV[0];
my $output_coding = $ARGV[1];
my $output_intron = $ARGV[2];
my $output_5primeUTR = $ARGV[3];
my $output_3primeUTR = $ARGV[4];

open(IN, $input) || die "cannot open $!";
open(OUT_EXON, ">" . $output_coding) || die "cannot open $!";
open(OUT_INTRON, ">" . $output_intron) || die "cannot open $!";
open(OUT_5PUTR, ">" . $output_5primeUTR) || die "cannot open $!";
open(OUT_3PUTR, ">" . $output_3primeUTR) || die "cannot open $!";

while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if ($F[1] =~ /^NM/) {
        my @starts = split(",", $F[9]);
        my @ends = split(",", $F[10]);

        for (my $i = 0; $i <= $#starts; $i++) {
            if (min($ends[$i], $F[6]) - $starts[$i] > 0) {
                if ($F[3] eq "+") {
                    print OUT_5PUTR $F[2]."\t".$starts[$i]."\t".min($ends[$i], $F[6])."\t". $F[12]."(".$F[1].")\n";
                } else {
                    print OUT_3PUTR $F[2]."\t".$starts[$i]."\t".min($ends[$i], $F[6])."\t". $F[12]."(".$F[1].")\n";
                }
            }
            if (min($ends[$i], $F[7]) - max($starts[$i], $F[6]) > 0) {
                print OUT_EXON $F[2]."\t".max($starts[$i], $F[6])."\t".min($ends[$i], $F[7])."\t".$F[12]."(".$F[1].")\n";
            }
            if ($ends[$i] - max($F[7], $starts[$i]) > 0) {
                if ($F[3] eq "+") { 
                    print OUT_3PUTR $F[2]."\t".max($F[7], $starts[$i])."\t".$ends[$i]."\t".$F[12]."(".$F[1].")\n";
                } else {
                    print OUT_5PUTR $F[2]."\t".max($F[7], $starts[$i])."\t".$ends[$i]."\t".$F[12]."(".$F[1].")\n";
                }
            }
        }
        for (my $i = 1; $i <= $#starts; $i++) {
            print OUT_INTRON $F[2]."\t".$ends[$i - 1]."\t".$starts[$i]."\t".$F[12]."(".$F[1].")\n";
        }
    }
}
close(IN);
close(OUT_EXON);
close(OUT_INTRON);
close(OUT_5PUTR);
close(OUT_3PUTR);
