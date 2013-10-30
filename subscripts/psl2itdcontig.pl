#! /usr/local/bin/perl

use strict;
use warnings;

my $input_psl = $ARGV[0];
my $input_list = $ARGV[1];
my $filt_itd_len = $ARGV[2];
my $output = $ARGV[3];

my %seqRecords = ();
my %filtIdRecords = ();
my %chrRecords = ();

my $cnt = 1;
open(INL, $input_list) || die "cannot open $!";
while(<INL>) {
  s/[\r\n\"]//g;
  my $line = $_;
  my @F = split("\t", $_);

  $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
  my $chr  = $1;
  $chrRecords{$cnt} = $chr;
  $cnt++;
}
close(INL);

open(IN, $input_psl) || die "cannot open $!";
while(<IN>) {
  next if (not $_ =~ /^\d/);
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
   
  if (not exists $seqRecords{$F[9]}) {
    $seqRecords{$F[9]} = $F[13]."\t".($F[15] + 1)."\t".$F[16]."\t".$F[0]."\t".$F[10]."\t".$F[18]."\t".$F[19]."\t".$F[20];
  }
  else {
    my @vals = split("\t", $seqRecords{$F[9]});
    if ($vals[3]  < $F[0]) {
      $seqRecords{$F[9]} = $F[13]."\t".($F[15] + 1)."\t".$F[16]."\t".$F[0]."\t".$F[10]."\t".$F[18]."\t".$F[19]."\t".$F[20];
    }
    elsif ($vals[3] ==  $F[0]) {
      my $chr =  $chrRecords{$F[9]};
      if ($F[13] eq $chr) {
        $seqRecords{$F[9]} = $F[13]."\t".($F[15] + 1)."\t".$F[16]."\t".$F[0]."\t".$F[10]."\t".$F[18]."\t".$F[19]."\t".$F[20];
      }
    } 
  }
}
close(IN);

my %itdposhash = ();
foreach my $key (sort keys %seqRecords) { 
  my @vals = split("\t", $seqRecords{$key});
  my $chrname  = $vals[0];
  my $startpos = $vals[1];
  my $endpos   = $vals[2];
  my $match    = $vals[3];
  my $contigsize  = $vals[4];
  my @blocksize = split(",", $vals[5]);
  my @qstarts = split(",", $vals[6]);
  my @tstarts = split(",", $vals[7]);

  my $startposcontig = $tstarts[0] - $qstarts[0];
  my $endposcontig   = $startposcontig + $contigsize;

  my $mapRate = ($match / $contigsize);
  my $itdkey = $chrname.":".$startpos."-".$endpos;
      
  my @itdposar = ();
  my $tmpstart = 0;

  for (my $i = 0; $i <= $#blocksize; $i++) {
    
    if ($i == 0) {
      my $itdlen = $qstarts[0];
      if ($itdlen >= $filt_itd_len) {
        my $itdendpos   = $tstarts[0] + 1;
        my $itdpos = "0" ."\t". $qstarts[0] ."\t". $startpos ."\t". $itdendpos . "\t". $chrname ."\t". $contigsize."\t".$startpos."\t".$endpos;
        push(@itdposar, $itdpos);
        next;
      }
    }
         
    if ($i != 0) {
      my $itdstartblock = ($blocksize[$i - 1] + $qstarts[$i - 1]);
      my $itdendblock = $qstarts[$i];
      my $itdlen = $itdendblock - $itdstartblock;

      if ($itdlen >= $filt_itd_len) {
        my $itdstartpos = $tstarts[$i];
        my $itdendpos   = $tstarts[$i] + 1;
        my $itdpos = $itdstartblock."\t".$itdendblock."\t".$itdstartpos."\t".$itdendpos."\t".$chrname."\t".$contigsize."\t".$startpos."\t".$endpos;
        push(@itdposar, $itdpos);
        next;
      }
    }

    if ($i == $#blocksize) {
      my $itdstartblock = ($blocksize[$i - 1] + $qstarts[$i - 1]);
      my $itdendblock = $contigsize;
      my $itdlen = $itdendblock - $itdstartblock;
            
      if ($itdlen >= $filt_itd_len) {
        my $itdstartpos = $tstarts[$i] + $blocksize[$i];
        my $itdpos = $itdstartblock ."\t". $itdendblock ."\t". $itdstartpos ."\t". $endpos ."\t". $chrname."\t".$contigsize."\t".$startpos."\t".$endpos;
        push(@itdposar, $itdpos);
        next;
      }
    }
  }

  $itdposhash{$key} = \@itdposar;
}

open(OUT, ">" . $output) || die "cannot open $!";
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
    
    my $itdcontig = $F[16];
      
    my @itdposar = @{$itdposhash{$key}};

    foreach my $itdposval (@itdposar) {
      
      my @vals = split("\t", $itdposval);
      my $itdstartblock = $vals[0];
      my $itdendblock   = $vals[1];
      my $itdstartpos   = $vals[2];
      my $itdendpos     = $vals[3];
      my $itdchr        = $vals[4];
      my $contigsize    = $vals[5];
      my $contigstart   = $vals[6];
      my $contigend     = $vals[7];
     
      my $itdlen = $itdendblock - $itdstartblock;
      next if(not defined $itdcontig);
      my $itdseq = substr($itdcontig, $itdstartblock, $itdlen);
      
      if (($chr11 eq $itdchr) and
        (((($pos11 - 10) < $itdstartpos) and ($itdstartpos < ($pos11 + 10))) or
         ((($pos12 - 10) < $itdstartpos) and ($itdstartpos < ($pos12 + 10))) or
         ((($pos21 - 10) < $itdstartpos) and ($itdstartpos < ($pos21 + 10))) or
         ((($pos22 - 10) < $itdstartpos) and ($itdstartpos < ($pos22 + 10))) or
         ((($pos11 - 10) < $itdendpos)   and ($itdendpos   < ($pos11 + 10))) or
         ((($pos12 - 10) < $itdendpos)   and ($itdendpos   < ($pos12 + 10))) or
         ((($pos21 - 10) < $itdendpos)   and ($itdendpos   < ($pos21 + 10))) or
         ((($pos22 - 10) < $itdendpos)   and ($itdendpos   < ($pos22 + 10))))) {

        print OUT $line."\t";
        print OUT $itdseq ."\t". $itdlen ."\t". $itdstartpos ."\t". $itdendpos ."\t". $itdchr ."\t". $contigstart ."\t". $contigend ."\n";
      }
      else {
        print OUT $line."\t";
        print OUT ""      ."\t". ""      ."\t". ""           ."\t". ""         ."\t". ""      ."\t". ""           ."\t". ""         ."\n";
      }
    }
  } else {
        print OUT $line."\t";
        print OUT ""      ."\t". ""      ."\t". ""           ."\t". ""         ."\t". ""      ."\t". ""           ."\t". ""         ."\n";
  }
  $line_count++;
         
}
close(INL);
close(OUT);


