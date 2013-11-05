#! /usr/local/bin/perl

use strict;

my $input_itdlist = $ARGV[0];
my $input_inhouse = $ARGV[1];

my %inhouse_keys = ();
open(IN, $input_inhouse) || die "cannot open $input_inhouse";
while(<IN>) {
  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $chr1 = $F[0];
  my $spos1 = $F[1];
  my $epos1 = $F[2];
  my $chr2 = $F[3];
  my $spos2 = $F[4];
  my $epos2 = $F[5];
  my $sample_support = $F[6];

  my $key = $chr1 ."\t". $spos1 ."\t". $epos1 ."\t". $chr2 ."\t". $spos2 ."\t". $epos2;

  $inhouse_keys{$key} = $inhouse_keys{$key} .";". $sample_support;

}
close(IN);

open(IN, $input_itdlist) || die "cannot open $input_itdlist";
while(<IN>) {
  s/[\r\n]//g;
  my @F = split("\t", $_);
  my $chr1 = $F[0];
  my $spos1 = $F[1];
  my $epos1 = $F[2];
  my $chr2 = $F[3];
  my $spos2 = $F[4];
  my $epos2 = $F[5];
  my $linekey1 = $F[6];
  my $linekey2 = $F[7];

  my $key = $chr1 ."\t". $spos1 ."\t". $epos1 ."\t". $chr2 ."\t". $spos2 ."\t". $epos2;
  if ( exists $inhouse_keys{$key}) {
    my $sample_support = $inhouse_keys{$key};
    my @valsArr = split(";", $sample_support);
    foreach my $val (@valsArr) {
      if (length($val) > 0) { 
        print $linekey1 ."\t". $linekey2 ."\t". $val ."\n";
      }
    }
  }
}
close(IN);

