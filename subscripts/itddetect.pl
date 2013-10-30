#! /usr/local/bin/perl


my $input_list = $ARGV[0];
my $output = $ARGV[1];

open(OUT, ">" . $output) || die "cannot open $output";
open(INL, $input_list) || die "cannot open $input_list";
while(<INL>) {

    s/[\r\n\"]//g;
    my $line = $_;
    my @F = split("\t", $_);

    my $oin_len = $F[18];
    my $oin_chr = $F[21];
    my $oin_start = $F[19];
    my $oin_end = $F[20];
    my $contig_start = $F[22];
    my $contig_end = $F[23];
    my $oin_align_cnt1 = $F[24];
    my $oin_align_cnt2 = $F[25];

    if ($oin_len ne "" and $oin_len > 0) {
      my $pdn_len = 0;
      my $oin_align_cnt = 0;
      
      if ($oin_align_cnt1 > $oin_align_cnt2) {
       
        $oin_align_cnt = $oin_align_cnt1;
        $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
        my $pos11 = $3;
        my $pos12 = $6;
        $pdn_len = $pos11 - ($pos12 - 1);
        
        my $clip1 = $7;
        if (defined $clip1 and $clip1 ne "") {
           $oin_len = $oin_len - length($clip1);
        }
      }
      else {
        
        $oin_align_cnt = $oin_align_cnt2;
        $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
        my $pos21 = $3;
        my $pos22 = $6;
        $pdn_len = $pos22 - ($pos21 - 1);
        
        my $clip2 = $7;
        if (defined $clip2 and $clip2 ne "") {
           $oin_len = $oin_len - length($clip2);
        }
      }
     
      next if ($oin_len <= 0);

      my $junction = "1.2";
      if ($oin_align_cnt1 > $oin_align_cnt2) {
        $junction = 1;
      } elsif ($oin_align_cnt1 < $oin_align_cnt2) {
        $junction = 2;
      }

      my $alignment_percent = ($oin_align_cnt / $pdn_len);
      my $length_percent = ($oin_len / $pdn_len);
      my $oin_alignment_percent = ($oin_align_cnt / $oin_len);

      my $itdcheck = "";
      if ($oin_start != $contig_start and $oin_end != $contig_end and $length_percent >= 0.8 and $length_percent <= 1.2 and $oin_alignment_percent >= 0.9) {
        $itdcheck = "Grade_A";
      }
      elsif (($oin_start != $contig_start or $oin_end != $contig_end) and $length_percent >= 0.8 and $length_percent <= 1.2 and $oin_alignment_percent >= 0.9) {
        $itdcheck = "Grade_B";
      }
      elsif (($oin_start != $contig_start or $oin_end != $contig_end) and ($length_percent >= 0.8 and $length_percent <= 1.2 or $oin_len >= 30) and $oin_alignment_percent >= 0.9) {
        $itdcheck = "Grade_C";
      }
      if ($oin_start == $oin_end) {
        if ($contig_start == $oin_end) {
          $oin_start = "---" 
        }
        elsif ($contig_end == $oin_start) {
          $oin_end = "---" 
        }
      }
      print OUT join("\t", @F[0 .. 5])."\t";
      print OUT $oin_chr ."\t". $contig_start ."\t". $contig_end ."\t";
      print OUT $F[16]."\t"; 
      print OUT length($F[16])."\t"; 
      print OUT $oin_chr ."\t". $oin_start ."\t". $oin_end ."\t";
      print OUT $F[17]."\t"; 
      print OUT length($F[17])."\t"; 
      print OUT $pdn_len ."\t".$junction."\t".$length_percent."\t".$alignment_percent."\t".$oin_alignment_percent."\t".$itdcheck."\n";
    }

}
close(INL);
close(OUT);

