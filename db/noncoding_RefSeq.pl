#! /usr/local/bin/perl

my $input = $ARGV[0];
my $output_exon = $ARGV[1];
my $output_intron = $ARGV[2];

open(IN, $input) || die "cannot open $!";
open(OUT_EXON, ">" . $output_exon) || die "cannot open $!";
open(OUT_INTRON, ">" . $output_intron) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if ($F[1] =~ /^NR/) {

        my @starts = split(",", $F[9]);
        my @ends = split(",", $F[10]);

        for (my $i = 0; $i <= $#starts; $i++) {
            print OUT_EXON $F[2] . "\t" . $starts[$i] . "\t" . $ends[$i] . "\t". $F[12]."(".$F[1].")\n";
            # print OUT_EXON $F[2] . "\t" . $starts[$i] . "\t" . $ends[$i] . "\t". $F[12]."(".$F[1].")_NONCODING_EXON\n";
        }

        for (my $i = 1; $i <= $#starts; $i++) {
            print OUT_INTRON $F[2] . "\t" . $ends[$i - 1] . "\t" . $starts[$i] . "\t". $F[12]."(".$F[1].")\n";
            # print OUT_INTRON $F[2] . "\t" . $ends[$i - 1] . "\t" . $starts[$i] . "\t". $F[12]."(".$F[1].")_NONCODING_INTRON\n";
        }
    }
}
close(IN);
close(OUT_EXON);
close(OUT_INTRON);
