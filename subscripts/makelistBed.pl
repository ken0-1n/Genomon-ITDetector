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
    my $PDN_select = $F[18];
      
    my $chr = "";
    my $spos = 0;
    my $epos = 0;

    if ($PDN_select eq "PDN1") { 
      $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      $chr = $1;
      $spos = $6;
      $epos = $3;
    }
    else {
      $F[3] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
      $chr = $1;
      $spos = $3;
      $epos = $6;
    }
    
    print $chr ."\t". ($spos) ."\t". ($epos) . "\t" . $key . "\n"; 
     
}
close(INL);

