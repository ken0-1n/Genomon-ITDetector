#! /usr/local/bin/perl

use strict;
use warnings;

my $input_psl = $ARGV[0];
my $input_list = $ARGV[1];
my $filt_itd_len = $ARGV[2];

my %seqRecords = ();

open(IN, $input_psl) || die "cannot open $!";
while(<IN>) {
  next if (not $_ =~ /^\d/);
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $line = $_;
   
  if (not exists $seqRecords{$F[9]}) {
    $seqRecords{$F[9]} = $line;
  }
  else {
    my @vals = split("\t", $seqRecords{$F[9]});
    if ($vals[0] < $F[0]) {
      $seqRecords{$F[9]} = $line;
    }
  }
}
close(IN);

my %itdposhash = ();
foreach my $key (sort keys %seqRecords) { 
  my @F = split("\t", $seqRecords{$key});
  my $q_size  = $F[10];
  my $q_end   = $F[12];
  my $t_chr   = $F[13];
  my $t_start = $F[15];
  my $t_end   = $F[16];
  my @blocksize = split(",", $F[18]);
  my @q_starts  = split(",", $F[19]);
  my @t_starts  = split(",", $F[20]);

  my @itdposar = ();
  my $cursor = 0;
  
  for (my $i = 0; $i <= $#blocksize; $i++) {
    
    if ($i == 0) {
      my $block_len = $q_starts[0];
      if ($block_len >= $filt_itd_len) {
        my $oin_end_pos   = $t_starts[0] + 1;
        my $itdpos = "0"."\t".$q_starts[0]."\t".$t_start."\t".$oin_end_pos."\t".$t_chr."\t".($t_start + 1)."\t".$t_end;
        push(@itdposar, $itdpos);
        $cursor = $cursor + $block_len + $blocksize[0];
        next;
      }
    }
         
    if ($i != 0) {
      my $itd_start_block = ($blocksize[$i - 1] + $q_starts[$i - 1]);
      my $itd_end_block = $q_starts[$i];
      my $block_len = $itd_end_block - $itd_start_block;

      if ($block_len >= $filt_itd_len) {
        my $oin_start_pos = $t_starts[$i];
        my $oin_end_pos   = $t_starts[$i] + 1;
        my $itdpos = $itd_start_block."\t".$itd_end_block."\t".$oin_start_pos."\t".$oin_end_pos."\t".$t_chr."\t".($t_start + 1)."\t".$t_end;
        push(@itdposar, $itdpos);
        $cursor = $cursor + $block_len + $blocksize[$i - 1];
        next;
      }
    }

    if ($i == $#blocksize) {
      my $itd_start_block = ($blocksize[$i - 1] + $q_starts[$i - 1]);
      my $itd_end_block = $q_size;
      my $block_len = $itd_end_block - $itd_start_block;
            
      if ($block_len >= $filt_itd_len) {
        my $oin_start_pos = $t_starts[$i] + $blocksize[$i];
        my $itdpos = $itd_start_block ."\t". $itd_end_block ."\t". $oin_start_pos ."\t". $t_end ."\t". $t_chr."\t".($t_start + 1)."\t".$t_end;
        push(@itdposar, $itdpos);
        $cursor = $cursor + $block_len + $blocksize[$i - 1];
        next;
      }
    }
  }
  if ($cursor == $q_end and $q_end < $q_size) {
    my $block_len = $q_size - $q_end;
    if ($block_len >= $filt_itd_len) {
      my $itdpos = $q_end ."\t". $q_size ."\t". $t_end ."\t". ($t_end + $block_len)."\t". $t_chr."\t".($t_start + 1)."\t".$t_end;
      push(@itdposar, $itdpos);
    }
  }
  $itdposhash{$key} = \@itdposar;
}

my $line_count = 1;
open(INL, $input_list) || die "cannot open $!";
while(<INL>) {

  s/[\r\n\"]//g;
  my $line = $_;
  my @F = split("\t", $_);
  
  my $key = $line_count;
  if (exists $itdposhash{$key}) {
  
    $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr11 = $1;
    my $pos11 = $3;
    my $pos12 = $6;

    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr21 = $1;
    my $pos21 = $3;
    my $pos22 = $6;
    
    my $assembledContig = $F[14];
    next if(not defined $assembledContig);
      
    my @itdposar = @{$itdposhash{$key}};

    foreach my $itdposval (@itdposar) {
    
      my @vals = split("\t", $itdposval);
      my $itd_start_block = $vals[0];
      my $itd_end_block   = $vals[1];
      my $oin_start_pos   = $vals[2];
      my $oin_end_pos     = $vals[3];
      my $contig_chr      = $vals[4];
      my $contig_start    = $vals[5];
      my $contig_end      = $vals[6];
     
      my $block_len = $itd_end_block - $itd_start_block;
      my $oin_seq = substr($assembledContig, $itd_start_block, $block_len);

      if (($chr11 eq $contig_chr) and
         ((abs($pos11 - $oin_start_pos) <= 10 ) or
          (abs($pos12 - $oin_start_pos) <= 10 ) or
          (abs($pos21 - $oin_start_pos) <= 10 ) or
          (abs($pos22 - $oin_start_pos) <= 10 ) or
          (abs($pos11 - $oin_end_pos)   <= 10 ) or
          (abs($pos12 - $oin_end_pos)   <= 10 ) or
          (abs($pos21 - $oin_end_pos)   <= 10 ) or
          (abs($pos22 - $oin_end_pos)   <= 10 ))) {

        print $line."\t";
        print $oin_seq ."\t". $block_len ."\t". $oin_start_pos ."\t". $oin_end_pos ."\t". $contig_chr ."\t". $contig_start ."\t". $contig_end ."\n";
      }
    }
  }
  $line_count++;
}
close(INL);


