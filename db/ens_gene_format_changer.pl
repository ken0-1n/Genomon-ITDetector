
use strict;
use warnings;

my $input = $ARGV[0];

open(IN, $input) || die "cannot open $!";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  my $chr = $F[2];
  my $start = $F[4];
  my $end = $F[5];
  my $gene = $F[1];

  print $chr . "\t" . $start . "\t" . $end . "\t" . $gene . "\n";
}
close(IN);

