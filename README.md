Genomon-ITDetector
==================

Genomon-ITDetector is a software package for internal tandem duplication detection from cancer genome sequencing data.

Dependecy
----------

* [blat](http://genome.ucsc.edu/)
* [bedtools](https://code.google.com/p/bedtools/)
* [CAP3](http://seq.cs.iastate.edu/)
* [fasta36](http://faculty.virginia.edu/wrpearson/fasta/fasta36/)
* [SAMtools](http://samtools.sourceforge.net/)
* [refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt from the UCSC site](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/)

SetUp
----------

1. Download the Genomon-ITDetector package to any directory.

2. Download and install following external tools to any directory.  
  **blat**  (Ver. 34x13).  
  **bedtools** (Ver. 2.14.3).  
  **CAP3**  (Ver.Date: 12/21/07).  
  **fasta36** (Ver. 3.5c).  
  **SAMtools** (Ver. 0.1.18).  

3. Download refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt from **the UCSC site** and place them under the Genomon-ITDetector-master/db directory, and unpack them.  

4. create a 2bit hg19 human genome reference and a 11.ooc file for blat.  
  *change dir to the blat dir and create 2bit reference genome:   
  **$ ./faToTwoBit in.fa out.2bit**  
  *create 11.ooc file:   
  **$ ./blat -makeOoc=11.ooc -repMatch=2253 -tileSize=11 out.2bit test.fa test.psl**  

5. Open config.env and set each entry.  
  **PATH_TO_HG19REF**: the path to the reference genome (.fasta) to which your sequence data is aligned.(we just test on the hg19 human genome reference from the UCSC site.)  
  **PATH_TO_BLAT_REF**: the path to the 2bit hg19 human genome reference (.2bit) you created in the SetUp section 4.  
  **PATH_TO_BLAT_OOC**: the path to the 11.ooc file you created in the SetUp section 4.  
  **PATH_TO_BLAT**: the path to the blat executable  
  **PATH_TO_BED_TOOLS**: the path to the BEDtools executable  
  **PATH_TO_CAP3**: the path to the CAP3 executable  
  **PATH_TO_FASTA**: the path to the fasta36 executable  
  **PATH_TO_SAMTOOLS**: the path to the SAMtools executable  


Usage
---

The command for creating the annotation database

    $ bash createAnnoDB.sh

The command for detecting ITDs

    $ bash detectITD.sh <path to the target bam file> <path to the output directory> <sample name>

You will get the "itd_list.tsv" in the specified output directory.


Test run
---

Use the following command

    $ bash detectITD.sh testdata/testin.bam testout testsample

The result ("itd_list.tsv") will be stored in the testout directory.


Create inhouse database
---

For filtering out polymorphisms and artifacts that are commonly occured among multiple samples

Please open inhouse/normal_inhouse_itd.list †,   
and add the paths of "inhouse_itd.tsv" † files for each of control samples. For example,   

    $ /home/your_username/output/control_sample01/inhouse_itd.tsv
    $ /home/your_username/output/control_sample02/inhouse_itd.tsv
    $ /home/your_username/output/control_sample03/inhouse_itd.tsv
    …
    $ /home/your_username/output/control_sample50/inhouse_itd.tsv

† Please do not change the file name.   
† The file "inhouse_itd.tsv" is the file which contains the outputs obtained from detectITD.sh   

Please open inhouse/normal_inhouse_breakpoint.list †,   
and add the paths of "inhouse_breakpoint.tsv" † files for each of control samples. For example,   

    $ /home/your_username/output/control_sample01/inhouse_breakpoint.tsv
    $ /home/your_username/output/control_sample02/inhouse_breakpoint.tsv
    $ /home/your_username/output/control_sample03/inhouse_breakpoint.tsv
    …
    $ /home/your_username/output/control_sample50/inhouse_breakpoint.tsv

† Please do not change the file name.   
† The "inhouse_breakpoint.tsv" is the file which contains the outputs obtained from detectITD.sh   


Output
---

The results are formatted as TSV format.

The followings are the information of the columns of the output file:   

</table>
  **ITD_breakpoint_pair(ITD-BPP)**: The positions of ITD breakpoint pairs. Plus(+) and minus(-) indicate the right and left breakpoint.  
  **supported_reads(strand+)supported_reads(strand-)**: The ratio of the supported reads aligned to positive(negative) strand.   
  **average_depth**: The average sequencing depths    
  **chr(contig) start_position(contig) end_position(contig)**: The positions of assembled contig sequences.   
  **assembled_contig_sequence**: The contig sequences by assembling support reads and their mate pairs.   
  **length**: The lengths of assembled contig sequences.   
  **chr(OIN) start_position(OIN) end_position(OIN)**: The position of OIN.  
  **observed_inserted_nucleotide(OIN)**: Unmapped parts of contig sequences.  
  **length(OIN) length(PDN)**: The lengths of OIN and PDN.   
  **selected_ITD-BPP"**: The reliability of ITD-BPP (1 or 2). If the pairs of ITD-BPP are idential, '1,2' is outputed.   
  **matched_bases / length(PDN)**: the number of matched bases between OIN and PDN / length of PDN.   
  **length(OIN) / length(PDN)**: length of OIN / length of PDN.   
  **matched_bases / length(OIN)**: the number of matched bases between OIN and PDN / length of OIN.  
  **exon intron 5putr 3putr noncoding_exon noncoding_intron**: RefSeq Gene Name and Gene ID.   
  **ens_gene**: Ensamble Gene ID.  
  **known_gene**: Known Gene ID.  
  **tandem_repeat**: Simple Repeat annotation.  
  **inhouse inhouse_left_breakpoint inhouse_right_breakpoint**: The results of matching ITD to inhouse database.       
  **grade**: grade (one of A, B and C) 


Copyright
----------
Copyright (c) 2013, Kenichi Chiba, Yuichi Shiraishi

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * We ask you to cite one of the following papers using this software.
  	** ""

"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 


