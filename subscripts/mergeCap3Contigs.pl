#! /usr/loca/bin/perl

use strict;
use warnings;

my $file = $ARGV[0];

my $tmpcontig;
my $contig1;
my $contig2;
open(IN, $file) || die "cannot open $file";
while(<IN>) {
  next if (/^\#/);
  s/[\r\n]//g;
  
  next if ($_ =~ /^>Contig1/);
 
  if ($_ =~ /^>Contig2/){
    $contig1 = $tmpcontig;
    $tmpcontig = "";
    next;
  }
  $tmpcontig = $tmpcontig.$_;
}
close(IN);
$contig2 = $tmpcontig;


my $newcontig = "";
for ( my $i = 20; $i >= 6; $i-- ) {
  my $subContig11 = substr($contig1,0,$i);
  my $subContig21 = substr($contig2,-($i));
  
  my $subContig12 = substr($contig1,-($i));
  my $subContig22 = substr($contig2,0,$i);
    
  if ($subContig11 eq $subContig21) {
    substr($contig2,-($i)) = "";
    $newcontig = $contig2.$contig1;
    open(OUT, ">".$file) || die "cannot open $file";
    print OUT ">Contig1\n";
    print OUT $newcontig ."\n";
    close(OUT);
    print 0;
  }
  elsif ($subContig12 eq $subContig22) {
    substr($contig1,-($i)) = "";
    $newcontig = $contig1.$contig2;
    open(OUT, ">".$file) || die "cannot open $file";
    print OUT ">Contig1\n";
    print OUT $newcontig ."\n";
    close(OUT);
    print 0;
  }
}
print 1;


