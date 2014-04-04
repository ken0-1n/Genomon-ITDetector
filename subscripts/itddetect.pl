#! /usr/local/bin/perl

use strict;
use warnings;

my $input_list = $ARGV[0];

open(IN, $input_list) || die "cannot open $input_list";
while(<IN>) {

    s/[\r\n\"]//g;
    my $line = $_;
    my @F = split("\t", $_);

    my $assembled_contig = $F[14];
    my $oin = $F[15];
    my $oin_len = $F[16];
    my $oin_chr = $F[19];
    my $oin_start = $F[17];
    my $oin_end = $F[18];
    my $contig_start = $F[20];
    my $contig_end = $F[21];
    my $selectPDN = $F[22];
    my $align_cnt = $F[23];

    if ($oin_len ne "" and $oin_len > 0) {
        my $epos = 0;
        my $spos = 0;
        my $clip = "";

        if ($selectPDN eq "PDN1") {
          $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
          $epos = $3;
          $spos = $6;
          $clip = $7;
        }
        else {
          $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
          $spos = $3;
          $epos = $6;
          $clip = $7;
        }
        
        my $pdn_len = $epos - ($spos - 1);
        my $oin_len = $oin_len - length($clip);
    
        if ($pdn_len > 0 and $oin_len > 0) {

            my $length_percent = ($pdn_len / $oin_len);
            my $pdn_alignment_percent = ($align_cnt / $pdn_len);
            my $oin_alignment_percent = ($align_cnt / $oin_len);

            my $itdcheck = "";
            if (($contig_start < $oin_start and $oin_end < $contig_end)
              and $length_percent >= 0.8 and $length_percent <= 1.2 and $pdn_alignment_percent >= 0.8 and $oin_alignment_percent >= 0.9) {
              $itdcheck = "Grade_A";
            }
            elsif (($oin_start == $contig_start or $oin_end == $contig_end or $oin_start == $contig_end or $oin_end == $contig_start)
              and $length_percent >= 0.8 and $length_percent <= 1.2 and $pdn_alignment_percent >= 0.8 and $oin_alignment_percent >= 0.9) {
              $itdcheck = "Grade_B";
            }
            elsif (($oin_start == $contig_start or $oin_end == $contig_end or $oin_start == $contig_end or $oin_end == $contig_start)
              and (($length_percent >= 0.8 and $length_percent <= 1.2) or $oin_len >= 30) and $oin_alignment_percent >= 0.9) {
              $itdcheck = "Grade_C";
            }

            if ($contig_start == $oin_end) {
              $oin_start = "---" 
            }
            elsif ($contig_end == $oin_start) {
              $oin_end = "---" 
            }
            
            print join("\t", @F[0 .. 5])."\t";
            print $oin_chr ."\t". $contig_start ."\t". $contig_end ."\t";
            print $assembled_contig."\t"; 
            print length($assembled_contig)."\t"; 
            print $oin_chr ."\t". $oin_start ."\t". $oin_end ."\t";
            print $oin."\t"; 
            print $oin_len."\t"; 
            print $pdn_len ."\t".$selectPDN."\t".$length_percent."\t".$pdn_alignment_percent."\t".$oin_alignment_percent."\t".$itdcheck."\n";
        }
    }
}
close(IN);

