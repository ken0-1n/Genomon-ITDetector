#! /bin/bash

configfile=./config.env
if [ ! -f $configfile ]; then
  echo "$configfile does not exists."
  exit 1
fi
source $configfile

refGene=db/refGene.txt
knownGene=db/knownGene.txt
ensGene=db/ensGene.txt
sRepeat=db/simpleRepeat.txt

if [ ! -f $refGene ]; then
  echo "$refGene does not exists."
  exit 1
fi
if [ ! -f $knownGene ]; then
  echo "$knownGene does not exists."
  exit 1
fi
if [ ! -f $ensGene ]; then
  echo "$ensGene does not exists."
  exit 1
fi
if [ ! -f $sRepeat ]; then
  echo "$sRepeat does not exists."
  exit 1
fi

perl db/coding_RefSeq.pl $refGene db/refGene.coding.exon.bed db/refGene.coding.intron.bed db/refGene.coding.5putr.bed db/refGene.coding.3putr.bed

${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.exon.bed   -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.exon.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.intron.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.intron.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.5putr.bed  -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.5putr.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.coding.3putr.bed  -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.coding.3putr.bed

perl db/noncoding_RefSeq.pl $refGene db/refGene.noncoding.exon.bed db/refGene.noncoding.intron.bed

${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.noncoding.exon.bed   -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.noncoding.exon.bed
${PATH_TO_BEDTOOLS}/mergeBed -i db/refGene.noncoding.intron.bed -nms | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/refGene.merged.noncoding.intron.bed

perl db/known_gene_format_changer.pl $knownGene | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/gene.known.sort.bed
perl db/ens_gene_format_changer.pl   $ensGene   | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/gene.ens.sort.bed
perl db/s_repeat_format_changer.pl   $sRepeat   | ${PATH_TO_BEDTOOLS}/sortBed -i stdin > db/gene.repeat.sort.bed

