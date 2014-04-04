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

<<<<<<< HEAD
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

=======
4. create a 2bit hg19 human genome reference and a 11.ooc file for blat.  
  *change dir to the blat dir and create 2bit reference genome:   

       $ ./faToTwoBit hg19.fasta out.2bit

  *create 11.ooc file:   
         
       $ ./blat -makeOoc=11.ooc -repMatch=2253 -tileSize=11 out.2bit temp.fa temp.psl  

5. Open config.env and set each entry.  
<table>
<tr>
<th>PATH_TO_HG19REF</th>
<td>the path to the reference genome (.fasta) to which your sequence data is aligned.(we just test on the hg19 human genome reference from the UCSC site.)</td>  
</tr>
<tr>
<th>PATH_TO_BLAT_REF</th>
<td>the path to the 2bit hg19 human genome reference (.2bit) you created in the SetUp section 4.</td>  
</tr>
<tr>
<th>PATH_TO_BLAT_OOC</th>
<td>the path to the 11.ooc file you created in the SetUp section 4.</td>  
</tr>
<tr>
<th>PATH_TO_BLAT</th>
<td>the path to the blat executable</td>  
</tr>
<tr>
<th>PATH_TO_BED_TOOLS</th>
<td>the path to the BEDtools executable</td>  
</tr>
<tr>
<th>PATH_TO_CAP3</th>
<td>the path to the CAP3 executable</td>  
</tr>
<tr>
<th>PATH_TO_FASTA</th>
<td>the path to the fasta36 executable</td>  
</tr>
<tr>
<th>PATH_TO_SAMTOOLS</th>
<td>the path to the SAMtools executable</td>  
</table>
>>>>>>> 07fce0e20ec1ad93c548155a3ecbdc9feae12549

How to run
---

Create the annotation database

    $ bash createAnnoDB.sh

Just type the following command

    $ bash detectITD.sh <path to the target bam file> <path to the output directory>

Then you will get the 'itd_list.tsv' under the specified output directory.


Test run
---

Just type the following command

    $ bash detectITD.sh testdata/testin.bam testout testsample


Output
---

<<<<<<< HEAD
The columns are exaplined below:   
  **ITD_breakpoint_pair(ITD-BPP)**:   
  **supported_reads(strand+)supported_reads(strand-)**:   
  **junction_len**:   
  **average_depth**:   
  **chr(contig) start_position(contig) end_position(contig)**:   
  **assembled_contig_sequence_length**:   
  **chr(OIN) start_position(OIN) end_position(OIN)**:   
  **observed_inserted_nucleotide(OIN)**:   
  **length(OIN) length(PDN)**:   
  **selected_ITD-BPP"**:   
  **matched_bases / length(PDN)**:   
  **length(OIN) / length(PDN)**:   
  **matched_bases / length(OIN)**:   
  **exon_intron 5putr 3putr noncoding_exon noncoding_intron**:   
  **ens_gene**:   
  **known_gene**:   
  **tandem_repeat**:   
  **inhouse**:   
  **inhouse_left_breakpoint**:   
  **inhouse_right_breakpoint**:   
  **grade**:   

=======
The results are formatted as TSV format.

The followings are the information of the columns of the output file:   

<table>
<tr>
<th>ITD_breakpoint_pair(ITD-BPP)_1</th>
<td>The positions of ITD breakpoint pairs. Plus(+) and minus(-) indicate the right and left breakpoint.</td>  
</tr>
<tr>
<th>supported_reads(strand+)<br>supported_reads(strand-)</th>
<td>The ratio of the supported reads aligned to positive(negative) strand.</td>
</tr>
<tr>
<th>ITD_breakpoint_pair(ITD-BPP)_2</th>
<td>The positions of ITD breakpoint pairs. Plus(+) and minus(-) indicate the right and left breakpoint.</td>  
</tr>
<tr>
<th>supported_reads(strand+)<br>supported_reads(strand-)</th>
<td>The ratio of the supported reads aligned to positive(negative) strand.</td>
</tr>
<tr>
<th>average_depth</th>
<td>The average sequencing depths</td>    
</tr>
<tr>
<th>chr(contig)<br>start_position(contig)<br>end_position(contig)</th>
<td>The positions of assembled contig sequences.</td>
</tr>
<tr>
<th>assembled_contig_sequence</th>
<td>The contig sequences by assembling support reads and their mate pairs.</td>
</tr>
<tr>
<th>length</th>
<td>The lengths of assembled contig sequences.</td>   
</tr>
<tr>
<th>chr(OIN)<br>start_position(OIN)<br>end_position(OIN)</th>
<td>The position of OIN.</td>  
</tr>
<tr>
<th>observed_inserted_nucleotide(OIN)</th>
<td>Unmapped parts of contig sequences.</td>  
</tr>
<tr>
<th>length(OIN)<br>length(PDN)</th>
<td>The lengths of OIN and PDN.</td>   
</tr>
<tr>
<th>selected_ITD-BPP</th>
<td>The reliability of ITD-BPP (1 or 2). If the pairs of ITD-BPP are idential, '1,2' is outputed.</td>   
</tr>
<tr>
<th>matched_bases / length(PDN)</th>
<td>the number of matched bases between OIN and PDN / length of PDN.</td>   
</tr>
<tr>
<th>length(OIN) / length(PDN)</th>
<td>length of OIN / length of PDN.</td>   
</tr>
<tr>
<th>matched_bases / length(OIN)</th>
<td>the number of matched bases between OIN and PDN / length of OIN.</td>  
</tr>
<tr>
<th>exon<br>intron<br>5putr<br>3putr<br>noncoding_exon<br>noncoding_intron</th>
<td>RefSeq Gene Name and Gene ID annotation.</td>   
</tr>
<tr>
<th>ens_gene</th>
<td>Ensamble Gene ID annotation.</td>  
</tr>
<tr>
<th>known_gene</th>
<td>Known Gene ID annotation.</td>  
</tr>
<tr>
<th>tandem_repeat</th>
<td>Simple Repeat annotation.</td>  
</tr>
<tr>
<th>inhouse<br>inhouse_left_breakpoint<br>inhouse_right_breakpoint</th>
<td>The results of matching ITD to inhouse database.</td>       
</tr>
<tr>
<th>grade</th>
<td>grade (one of A, B and C)</td> 
</tr>
</table>
>>>>>>> 07fce0e20ec1ad93c548155a3ecbdc9feae12549

Copyright
----------
Copyright (c) 2013, Kenichi Chiba, Yuichi Shiraishi

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * We ask you to cite one of the following papers using this software.
  	** ""

"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 


