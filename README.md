Genomon-ITDetector
==================

Genomon-ITDetector is a software package for detecting internal tandem duplication (ITD) from genome sequence data.

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

2. Download and extract and install following external tools to any directory.  
  **blat**  (Ver. 34x13).  
  **bedtools** (Ver. 2.14.3).  
  **CAP3**  (Ver.Date: 12/21/07).  
  **fasta36** (Ver. 3.5c).  
  **SAMtools** (Ver. 0.1.18).  

3. Download the refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt files from **the UCSC site** and place them under the Genomon-ITDetector-master/db directory, and then unpack them.  

4. create a 11.ooc file and a 2bit hg19 human genome reference for blat.  
  change dir to the blat dir and create 2bit reference genome.  
  **$ ./faToTwoBit in.fa out.2bit**  
  create 11.ooc file.  
  **$ ./blat -makeOoc=11.ooc -repMatch=2253 -tileSize=11 out.2bit test.fa test.psl**  

5. Open config.env and set each entry.  
  **PATH_TO_HG19REF**: the path to the reference genome (.fasta) to which your sequence data is aligned.(we just test on the hg19 human genome reference from the UCSC site.)  
  **PATH_TO_BLAT_REF**: the path to the 2bit hg19 human genome reference (.2bit) you created in the SetUp 4 section.  
  **PATH_TO_BLAT_OOC**: the path to the 11.ooc file you created in the SetUp 4 section.  
  **PATH_TO_BLAT**: the path to the blat executable  
  **PATH_TO_BED_TOOLS**: the path to the BEDtools executable  
  **PATH_TO_CAP3**: the path to the CAP3 executable  
  **PATH_TO_FASTA**: the path to the fasta36 executable  
  **PATH_TO_SAMTOOLS**: the path to the SAMtools executable  


Usage
---

the command for creating the annotation database

    $ bash createAnnoDB.sh

the command for detecting ITDs

    $ bash detectITD.sh <path to the target bam file> <path to the output directory> <sample name>

Then you will get the 'itd_list.tsv' under the specified output directory.


Test run
---

Just type the following command

    $ bash detectITD.sh testdata/testin.bam testout testsample

Result is stored under the testout directory.


How to use inhouse data
---

Please open Genomon-ITDetector/inhouse/normal_inhouse_itd.list †,   
and list the paths of "inhouse_itd.tsv" † files as follows:   

    $ /home/your_username/Genomon-ITDetector/testsample01/inhouse_itd.tsv
    $ /home/your_username/Genomon-ITDetector/testsample02/inhouse_itd.tsv
    $ /home/your_username/Genomon-ITDetector/testsample03/inhouse_itd.tsv
    $ …
    $ /home/your_username/Genomon-ITDetector/testsample50/inhouse_itd.tsv

† please do not change the file name.   
† "inhouse_itd.tsv" is the file which contains the outputs obtained from detectITD.sh   

Please open Genomon-ITDetector/inhouse/normal_inhouse_breakpoint.list †,   
and list the paths of "inhouse_breakpoint.tsv" † files as follows:

    $ /home/your_username/Genomon-ITDetector/testsample01/inhouse_breakpoint.tsv
    $ /home/your_username/Genomon-ITDetector/testsample02/inhouse_breakpoint.tsv
    $ /home/your_username/Genomon-ITDetector/testsample03/inhouse_breakpoint.tsv
    $ …
    $ /home/your_username/Genomon-ITDetector/testsample50/inhouse_breakpoint.tsv

† please do not change the file name.   
† "inhouse_breakpoint.tsv" is the file which contains the outputs obtained from detectITD.sh   


Output
---

results are formatted as TSV format.

The columns are exaplined below:   

</table>
  **ITD_breakpoint_pair(ITD-BPP)**:   
  **supported_reads(strand+)supported_reads(strand-)**: ratio of supported reads aligned to positive(negative) strand.   
  **average_depth**: average sequencing depths    
  **chr(contig) start_position(contig) end_position(contig)**: position of assembled contig sequence.   
  **assembled_contig_sequence**: contig sequence of assembling support reads and their mape pairs.   
  **length**: length of assembled contig sequence.   
  **chr(OIN) start_position(OIN) end_position(OIN)**: position of OIN.  
  **observed_inserted_nucleotide(OIN)**: unmapped part on contig sequencing.  
  **length(OIN) length(PDN)**: length of OIN and PDN.   
  **selected_ITD-BPP"**: reliability ITD-BPP (1 or 2). If the ITD-BPP is the same, '1,2' is output.   
  **matched_bases / length(PDN)**: the number of matched bases between OIN and PDN / length of PDN.   
  **length(OIN) / length(PDN)**: length of OIN / length of PDN.   
  **matched_bases / length(OIN)**: the number of matched bases between OIN and PDN / length of OIN.  
  **exon intron 5putr 3putr noncoding_exon noncoding_intron**: RefSeq Gene Name and Gene ID.   
  **ens_gene**: Ensamble Gene ID.  
  **known_gene**: Known Gene ID.  
  **tandem_repeat**: Simple Repeat annotation. Output "trf", if overlap between ITD-BPP and simple repeat regions.  
  **inhouse inhouse_left_breakpoint inhouse_right_breakpoint**: control sample name and supported read.       
  **grade**: grade (one of A, B, C) 


Copyright
----------
Copyright (c) 2013, Kenichi Chiba, Yuichi Shiraishi

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * We ask you to cite one of the following papers using this software.
  	** ""

"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 


