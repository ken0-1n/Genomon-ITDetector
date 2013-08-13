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
* [Picard](http://picard.sourceforge.net/)
* [the UCSC site](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/)

SetUp
----------

1. Download the Genomon-ITDetector package to any directory.

2. Download and extract and install following external tools to any directory.  
  **blat**  (Ver. 34x13).  
  **bedtools** (Ver. 2.14.3).  
  **CAP3**  (Ver.Date: 12/21/07).  
  **fasta36** (Ver. 3.5c).  
  **SAMtools** (Ver. 0.1.18).  
  **Picard** (Ver. 1.39).  

3. Download the refGene.txt, knownGene.txt, ensGene.txt and simpleRepeat.txt files from the UCSC site and place them under the Genomon-ITDetector directory and unpack them.  

4. create a 11.ooc file and a 2bit reference genome for blat.  
  change dir to the blat dir and create 2bit reference genome.  
  **$ ./faToTwoBit in.fa out.2bit**  
  create 11.ooc file.  
  **$ ./blat -makeOoc=11.ooc -repMatch=2253 -tileSize=11 out.2bit test.fa test.psl**  
