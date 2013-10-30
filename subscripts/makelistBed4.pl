#! /usr/local/bin/perl

use strict;
use warnings;

my $input_list = $ARGV[0];

my %seqRecords = ();
my %filtIdRecords = ();

open(INL, $input_list) || die "cannot open $!";
while(<INL>) {

    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $key = $F[0]."\t".$F[3];
    my $itdselect = $F[11];
      
    my $chr = "";
    my $spos = 0;
    my $epos = 0;

    if ($itdselect == 1) { 
      $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      $chr = $1;
      $spos = $6 - 1;
      $epos = $3;
    }
    else {
      $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      $chr = $1;
      $spos = $3 - 1;
      $epos = $6;
    }
    
    print $chr ."\t". ($spos-4) ."\t". ($spos+6) . "\t" . $key . "\n"; 
    print $chr ."\t". ($epos-5) ."\t". ($epos+5) . "\t" . $key . "\n"; 
     
}
close(INL);

