# /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l s_vmem=6G,mem_req=6
#$ -q mjobs.q
#$ -e log 
#$ -o log 

only_annotation=0

# : <<'#__COMMENT_OUT__'
write_usage() {
  echo ""
  echo "Usage: `basename $0` <path to the target bam file> <path to the output directory> <sample name> [<inhouse directory>] [<config .env>]"
  echo ""
}
#__COMMENT_OUT__

readonly DIR=`dirname ${0}`
#readonly DIR=.
readonly INPUTBAM=$1
readonly TRDIR=$2
readonly SAMPLE_NAME=$3
INHOUSEDIR=$4
itd_env=$5

if [ $# -le 2 -o $# -ge 5 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi

if [ $# -eq 4 ]; then
  conf_dir=`echo $(cd ${DIR} && pwd)`
  itd_env=${DIR}/config.env
else
  conf_dir=`dirname ${itd_env}`
  conf_dir=`echo $(cd ${conf_dir} && pwd)`
  conf_file="${itd_env##*/}"
  itd_env=${conf_dir}/${conf_file}
fi

if [ ! -f ${itd_env} ]; then
  echo "${itd_env} does not exists."
  write_usage
  exit 1
fi

script_main_dir=`echo $(cd ${DIR} && pwd)`
readonly SCRIPTDIR=${script_main_dir}/subscripts
readonly DBDIR=${script_main_dir}/db
readonly UTIL=${SCRIPTDIR}/utility.sh

if [ -z $INHOUSEDIR ]; then
    INHOUSEDIR=${script_main_dir}/inhouse
fi

if [ ! -f ${UTIL} ]; then
  echo "${UTIL} does not exists."
  write_usage
  exit 1
fi

source ${itd_env}
source ${UTIL}

check_file_exists $INPUTBAM
check_mkdir $TRDIR
check_mkdir ${TRDIR}/tmp
check_file_exists ${DBDIR}/refGene.merged.coding.exon.bed
check_file_exists ${DBDIR}/refGene.merged.coding.intron.bed
check_file_exists ${DBDIR}/refGene.merged.coding.5putr.bed
check_file_exists ${DBDIR}/refGene.merged.coding.3putr.bed
check_file_exists ${DBDIR}/refGene.merged.noncoding.exon.bed
check_file_exists ${DBDIR}/refGene.merged.noncoding.intron.bed
check_file_exists ${DBDIR}/ensGene.merged.bed
check_file_exists ${DBDIR}/knownGene.merged.bed 
check_file_exists ${DBDIR}/simpleRepeat.merged.bed

# when identify ITD-BPPs, the soft-clipped fragments at two break points align to the other break points while allowing for whithin this parameter value of base
THRES_AMBIGUITY_RANGE=10
# the total number of support reads should be more than this parameter value
MIN_SUPPORT_READS=2
# sam filtering flag
SAM_FILTERING_FLAG=1292

echo "***** [$0] start " `date +'%Y/%m/%d %H:%M:%S'` " *****"

if [ $only_annotation -eq 0 ]; then
  echo "Step1. Search ITD Break Point."
  date

# : <<'#__COMMENT_OUT__'
  # 
  echo "${PATH_TO_SAMTOOLS}/samtools view -h -F $SAM_FILTERING_FLAG -q $THRES_MAP_QUALITY $INPUTBAM > ${TRDIR}/tmp/temp.input.sam"
  ${PATH_TO_SAMTOOLS}/samtools view -h -F $SAM_FILTERING_FLAG -q $THRES_MAP_QUALITY $INPUTBAM > ${TRDIR}/tmp/temp.input.sam
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/getCandJunc.pl ${TRDIR}/tmp/temp.input.sam $THRES_SOFT_CLIPPED_LENGTH $THRES_INSERTION_SIZE > ${TRDIR}/tmp/candJunc.fa"
  perl ${SCRIPTDIR}/getCandJunc.pl ${TRDIR}/tmp/temp.input.sam $THRES_SOFT_CLIPPED_LENGTH $THRES_INSERTION_SIZE > ${TRDIR}/tmp/candJunc.fa
  check_error $?
  #
  echo "${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -minScore=20 -ooc=${PATH_TO_BLAT_OOC} $PATH_TO_BLAT_REF ${TRDIR}/tmp/candJunc.fa ${TRDIR}/tmp/candJunc.psl"
  ${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -minScore=20 -ooc=${PATH_TO_BLAT_OOC} $PATH_TO_BLAT_REF ${TRDIR}/tmp/candJunc.fa ${TRDIR}/tmp/candJunc.psl
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/psl2junction2.pl ${TRDIR}/tmp/candJunc.psl ${TRDIR}/tmp/candJunc.txt ${TRDIR}/tmp/junc2ID.txt $THRES_MALTI_MAPPED $THRES_JUNC_INSERTION"
  perl ${SCRIPTDIR}/psl2junction2.pl ${TRDIR}/tmp/candJunc.psl ${TRDIR}/tmp/candJunc.txt ${TRDIR}/tmp/junc2ID.txt $THRES_MALTI_MAPPED $THRES_JUNC_INSERTION
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeBeds2.pl ${TRDIR}/tmp/candJunc.txt ${TRDIR}/tmp/cj1.bed ${TRDIR}/tmp/cj2.bed $THRES_MIN_ITD_LENGTH $THRES_MAX_ITD_LENGTH"
  perl ${SCRIPTDIR}/makeBeds2.pl ${TRDIR}/tmp/candJunc.txt ${TRDIR}/tmp/cj1.bed ${TRDIR}/tmp/cj2.bed $THRES_MIN_ITD_LENGTH $THRES_MAX_ITD_LENGTH
  check_error $?

  if [ -s ${TRDIR}/tmp/cj2.bed ]; then
    #
    echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${TRDIR}/tmp/cj1.bed -b ${TRDIR}/tmp/cj2.bed -wb > ${TRDIR}/tmp/candJunc.inter.txt"
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${TRDIR}/tmp/cj1.bed -b ${TRDIR}/tmp/cj2.bed -wb > ${TRDIR}/tmp/candJunc.inter.txt
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/tmp/candJunc.inter.txt
    check_error $?
  fi
  #
  echo "perl ${SCRIPTDIR}/mergeJunc22.pl ${TRDIR}/tmp/candJunc.inter.txt $THRES_AMBIGUITY_RANGE $MIN_SUPPORT_READS > ${TRDIR}/tmp/juncList12.txt"
  perl ${SCRIPTDIR}/mergeJunc22.pl ${TRDIR}/tmp/candJunc.inter.txt $THRES_AMBIGUITY_RANGE $MIN_SUPPORT_READS > ${TRDIR}/tmp/juncList12.txt
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/mergeSameData.pl ${TRDIR}/tmp/juncList12.txt > ${TRDIR}/tmp/juncList12.txt.merge1"
  perl ${SCRIPTDIR}/mergeSameData.pl ${TRDIR}/tmp/juncList12.txt > ${TRDIR}/tmp/juncList12.txt.merge1
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/mergeSameData2.pl ${TRDIR}/tmp/juncList12.txt.merge1 > ${TRDIR}/tmp/juncList12.txt.merge2"
  perl ${SCRIPTDIR}/mergeSameData2.pl ${TRDIR}/tmp/juncList12.txt.merge1 > ${TRDIR}/tmp/juncList12.txt.merge2
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeTargetIdSam.pl ${TRDIR}/tmp/juncList12.txt.merge2 ${TRDIR}/tmp/temp.input.sam > ${TRDIR}/tmp/targetId.sam"
  perl ${SCRIPTDIR}/makeTargetIdSam.pl ${TRDIR}/tmp/juncList12.txt.merge2 ${TRDIR}/tmp/temp.input.sam > ${TRDIR}/tmp/targetId.sam
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJunctionBed2.pl ${TRDIR}/tmp/candJunc.txt $SAMPLE_NAME $THRES_MIN_ITD_LENGTH $THRES_MAX_ITD_LENGTH > ${TRDIR}/inhouse_breakpoint.tsv"
  perl ${SCRIPTDIR}/makeJunctionBed2.pl ${TRDIR}/tmp/candJunc.txt $SAMPLE_NAME $THRES_MIN_ITD_LENGTH $THRES_MAX_ITD_LENGTH > ${TRDIR}/inhouse_breakpoint.tsv
  check_error $?

  rm ${TRDIR}/tmp/temp.input.sam
  rm ${TRDIR}/tmp/candJunc.psl
  rm ${TRDIR}/tmp/candJunc.fa
  rm ${TRDIR}/tmp/candJunc.txt
  rm ${TRDIR}/tmp/junc2ID.txt
  rm ${TRDIR}/tmp/cj1.bed
  rm ${TRDIR}/tmp/cj2.bed
  rm ${TRDIR}/tmp/candJunc.inter.txt
  rm ${TRDIR}/tmp/juncList12.txt.merge1
#__COMMENT_OUT__

  echo "Step2. Assemble Secence Data."
  date
# : <<'#__COMMENT_OUT__'

  #
  echo "perl ${SCRIPTDIR}/makeRef2.pl ${TRDIR}/tmp/juncList12.txt.merge2 > ${TRDIR}/tmp/juncList12.ref.bed"
  perl ${SCRIPTDIR}/makeRef2.pl ${TRDIR}/tmp/juncList12.txt.merge2 > ${TRDIR}/tmp/juncList12.ref.bed
  check_error $?

  if [ -s ${TRDIR}/tmp/juncList12.ref.bed ]; then
    #
    echo "${PATH_TO_BEDTOOLS}/fastaFromBed -fi ${PATH_TO_HG19REF} -bed ${TRDIR}/tmp/juncList12.ref.bed -fo ${TRDIR}/tmp/juncList12.ref.fasta -name -tab"
    ${PATH_TO_BEDTOOLS}/fastaFromBed -fi ${PATH_TO_HG19REF} -bed ${TRDIR}/tmp/juncList12.ref.bed -fo ${TRDIR}/tmp/juncList12.ref.fasta -name -tab
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/tmp/juncList12.ref.fasta
    check_error $?
  fi
  #
  echo "perl ${SCRIPTDIR}/addRef2.pl ${TRDIR}/tmp/juncList12.txt.merge2 ${TRDIR}/tmp/juncList12.ref.fasta > ${TRDIR}/tmp/juncList12.ref.txt"
  perl ${SCRIPTDIR}/addRef2.pl ${TRDIR}/tmp/juncList12.txt.merge2 ${TRDIR}/tmp/juncList12.ref.fasta > ${TRDIR}/tmp/juncList12.ref.txt
  check_error $?

  /bin/echo -n > ${TRDIR}/tmp/itdContig.fa
  check_error $?
  /bin/echo -n > ${TRDIR}/tmp/juncList12.contig.txt
  check_error $?

  count=1
  while read line; do
    seq_ids1=`echo "$line" | cut -f 7`
    seq_ids2=`echo "$line" | cut -f 8`
    
    pdn1left=`echo "$line" | cut -f 9`
    pdn1=`echo "$line" | cut -f 10`
    pdn1right=`echo "$line" | cut -f 11`
    pdn2left=`echo "$line" | cut -f 12`
    pdn2=`echo "$line" | cut -f 13`
    pdn2right=`echo "$line" | cut -f 14`
    
    pdn1contig=${pdn1left}${pdn1}${pdn1}${pdn1right}
    pdn2contig=${pdn2left}${pdn2}${pdn2}${pdn2right}

    #
    echo "${seq_ids1},${seq_ids2}" > ${TRDIR}/tmp/idseq.txt 
    check_error $?
    #
    echo "perl ${SCRIPTDIR}/makeCap3fa.pl ${TRDIR}/tmp/idseq.txt ${TRDIR}/tmp/targetId.sam > ${TRDIR}/tmp/temp.cap3.fa"
    perl ${SCRIPTDIR}/makeCap3fa.pl ${TRDIR}/tmp/idseq.txt ${TRDIR}/tmp/targetId.sam > ${TRDIR}/tmp/temp.cap3.fa
    check_error $?
    #
    echo "${PATH_TO_CAP3}/cap3 ${TRDIR}/tmp/temp.cap3.fa -j 31 -o 16 -s 251 -p 66 -i 21 > ${TRDIR}/tmp/temp.cap3.contig"
    ${PATH_TO_CAP3}/cap3 ${TRDIR}/tmp/temp.cap3.fa -j 31 -o 16 -s 251 -p 66 -i 21 > ${TRDIR}/tmp/temp.cap3.contig
    check_error $?
 
    if [ ! -s ${TRDIR}/tmp/temp.cap3.fa.cap.contigs ]; then
      continue;
    fi
    echo '>'query1 > ${TRDIR}/tmp/temp.fasta36.fa 
    echo $pdn1contig >> ${TRDIR}/tmp/temp.fasta36.fa 
    echo '>'query2 >> ${TRDIR}/tmp/temp.fasta36.fa 
    echo $pdn2contig >> ${TRDIR}/tmp/temp.fasta36.fa 
    
    #
    echo "${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/tmp/temp.cap3.fa.cap.contigs ${TRDIR}/tmp/temp.fasta36.fa > ${TRDIR}/tmp/temp.fasta36.fa.contigs.fastaTabular"
    ${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/tmp/temp.cap3.fa.cap.contigs ${TRDIR}/tmp/temp.fasta36.fa > ${TRDIR}/tmp/temp.fasta36.fa.contigs.fastaTabular
    check_error $?
    #
    echo "assembledContig=perl ${SCRIPTDIR}/extractContigSeq.pl ${TRDIR}/tmp/temp.cap3.fa.cap.contigs ${TRDIR}/tmp/temp.fasta36.fa.contigs.fastaTabular" 
    assembledContig=`perl ${SCRIPTDIR}/extractContigSeq.pl ${TRDIR}/tmp/temp.cap3.fa.cap.contigs ${TRDIR}/tmp/temp.fasta36.fa.contigs.fastaTabular`
    check_error $?

    echo '>'$count >> ${TRDIR}/tmp/itdContig.fa 
    check_error $?
    echo $assembledContig >> ${TRDIR}/tmp/itdContig.fa
    check_error $?
    echo -e "$line\t$assembledContig" >> ${TRDIR}/tmp/juncList12.contig.txt
    check_error $?
  
    count=$((count+1))
  done < ${TRDIR}/tmp/juncList12.ref.txt

  if [ -s ${TRDIR}/tmp/itdContig.fa ]; then
    # echo "${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -maxIntron=${THRES_MAX_ITD_LENGTH} ${PATH_TO_BLAT_REF} ${TRDIR}/tmp/itdContig.fa ${TRDIR}/tmp/itdContig.psl"
    # ${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -maxIntron=${THRES_MAX_ITD_LENGTH} ${PATH_TO_BLAT_REF} ${TRDIR}/tmp/itdContig.fa ${TRDIR}/tmp/itdContig.psl
    #
    echo "${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -maxIntron=1000 ${PATH_TO_BLAT_REF} ${TRDIR}/tmp/itdContig.fa ${TRDIR}/tmp/itdContig.psl"
    ${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -maxIntron=1000 ${PATH_TO_BLAT_REF} ${TRDIR}/tmp/itdContig.fa ${TRDIR}/tmp/itdContig.psl
    check_error $?
  else 
    /bin/echo -n > ${TRDIR}/tmp/itdContig.psl
    check_error $?
  fi
  #
  echo "perl ${SCRIPTDIR}/psl2itdcontig.pl ${TRDIR}/tmp/itdContig.psl ${TRDIR}/tmp/juncList12.contig.txt $THRES_MIN_ITD_LENGTH > ${TRDIR}/tmp/juncListitd12.txt"
  perl ${SCRIPTDIR}/psl2itdcontig.pl ${TRDIR}/tmp/itdContig.psl ${TRDIR}/tmp/juncList12.contig.txt $THRES_MIN_ITD_LENGTH > ${TRDIR}/tmp/juncListitd12.txt
  check_error $?

  rm ${TRDIR}/tmp/juncList12.ref.txt
  rm ${TRDIR}/tmp/juncList12.ref.fasta
  rm ${TRDIR}/tmp/temp.fasta36.fa.contigs.fastaTabular
  rm ${TRDIR}/tmp/temp.fasta36.fa
  rm ${TRDIR}/tmp/temp.cap3.fa.cap.singlets
  rm ${TRDIR}/tmp/temp.cap3.fa.cap.info
  rm ${TRDIR}/tmp/temp.cap3.fa.cap.contigs.qual
  rm ${TRDIR}/tmp/temp.cap3.fa.cap.contigs.links
  rm ${TRDIR}/tmp/temp.cap3.fa.cap.contigs
  rm ${TRDIR}/tmp/temp.cap3.fa.cap.ace
  rm ${TRDIR}/tmp/temp.cap3.fa
  rm ${TRDIR}/tmp/temp.cap3.contig
  rm ${TRDIR}/tmp/juncList12.contig.txt
  rm ${TRDIR}/tmp/itdContig.fa
  rm ${TRDIR}/tmp/idseq.txt
  rm ${TRDIR}/tmp/itdContig.psl
#__COMMENT_OUT__

  echo "Step3. Check Assembled Contigs."
  date

# <<'#__COMMENT_OUT__'
  /bin/echo -n > ${TRDIR}/tmp/juncListitd13.txt
  check_error $?

  while read line; do
    pdn1=`echo "$line" | cut -f 10`  # PDN1
    pdn2=`echo "$line" | cut -f 13`  # PDN2
    oin=` echo "$line" | cut -f 16`  # OIN
    
    if [ "${oin-UNDEF}" != "UNDEF" ]; then
      if [ "${oin}" != "" ]; then
        echo '>'PDN1 > ${TRDIR}/tmp/temp.fasta36.pdn.fa
        check_error $?
        echo $pdn1 >> ${TRDIR}/tmp/temp.fasta36.pdn.fa 
        check_error $?
        echo '>'PDN2 >> ${TRDIR}/tmp/temp.fasta36.pdn.fa 
        check_error $?
        echo $pdn2 >> ${TRDIR}/tmp/temp.fasta36.pdn.fa 
        check_error $?
        echo '>'OIN > ${TRDIR}/tmp/temp.fasta36.oin.fa 
        check_error $?
        echo $oin >> ${TRDIR}/tmp/temp.fasta36.oin.fa
        check_error $?

        #
        echo "${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/tmp/temp.fasta36.oin.fa ${TRDIR}/tmp/temp.fasta36.pdn.fa > ${TRDIR}/tmp/temp.fasta36.oin.fastaTabular"
        ${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/tmp/temp.fasta36.oin.fa ${TRDIR}/tmp/temp.fasta36.pdn.fa > ${TRDIR}/tmp/temp.fasta36.oin.fastaTabular
        check_error $?
        #
        echo "alignmentScore=perl ${SCRIPTDIR}/getAlignmentScore.pl ${TRDIR}/tmp/temp.fasta36.oin.fastaTabular"
        alignmentScore=`perl ${SCRIPTDIR}/getAlignmentScore.pl ${TRDIR}/tmp/temp.fasta36.oin.fastaTabular`
        check_error $?
        #
        echo -e "${line}\t${alignmentScore}" >> ${TRDIR}/tmp/juncListitd13.txt
        check_error $?
      fi
    fi
  done < ${TRDIR}/tmp/juncListitd12.txt

  #
  echo "perl ${SCRIPTDIR}/itddetect.pl ${TRDIR}/tmp/juncListitd13.txt > ${TRDIR}/tmp/juncListitd14.txt"
  perl ${SCRIPTDIR}/itddetect.pl ${TRDIR}/tmp/juncListitd13.txt > ${TRDIR}/tmp/juncListitd14.txt
  check_error $?
  
  rm ${TRDIR}/tmp/temp.fasta36.pdn.fa
  rm ${TRDIR}/tmp/temp.fasta36.oin.fastaTabular
  rm ${TRDIR}/tmp/temp.fasta36.oin.fa
  rm ${TRDIR}/tmp/juncListitd13.txt

#__COMMENT_OUT__

fi 
echo "Step4. Annotate."
date

# : <<'#__COMMENT_OUT__'
/bin/echo -n > ${TRDIR}/tmp/juncListitd14.depth.txt
check_error $?

if [ -s ${TRDIR}/tmp/juncListitd14.txt ]; then

  #
  echo "perl ${SCRIPTDIR}/addJunctionPosition.pl ${TRDIR}/tmp/juncListitd14.txt ${TRDIR}/tmp/temp.range.bed ${TRDIR}/tmp/juncListitd14.range.txt"
  perl ${SCRIPTDIR}/addJunctionPosition.pl ${TRDIR}/tmp/juncListitd14.txt ${TRDIR}/tmp/temp.range.bed ${TRDIR}/tmp/juncListitd14.range.txt
  check_error $?
  #
  echo "${PATH_TO_SAMTOOLS}/samtools view -h -b -F $SAM_FILTERING_FLAG -q $THRES_MAP_QUALITY -L ${TRDIR}/tmp/temp.range.bed $INPUTBAM > ${TRDIR}/tmp/temp.range.bam"
  ${PATH_TO_SAMTOOLS}/samtools view -h -b -F $SAM_FILTERING_FLAG -q $THRES_MAP_QUALITY -L ${TRDIR}/tmp/temp.range.bed $INPUTBAM > ${TRDIR}/tmp/temp.range.bam
  check_error $?
  #
  echo "${PATH_TO_SAMTOOLS}/samtools index ${TRDIR}/tmp/temp.range.bam"
  ${PATH_TO_SAMTOOLS}/samtools index ${TRDIR}/tmp/temp.range.bam
  check_error $?

  while read line; do
    bp_chr=`echo "$line" | cut -f 1`
    bp_start=`echo "$line" | cut -f 2`
    bp_end=`echo "$line" | cut -f 3`
    range=${bp_chr}":"${bp_start}"-"${bp_end}

    #
    echo "${PATH_TO_SAMTOOLS}/samtools depth -r $range ${TRDIR}/tmp/temp.range.bam > ${TRDIR}/tmp/temp.range.depth"
    ${PATH_TO_SAMTOOLS}/samtools depth -r $range ${TRDIR}/tmp/temp.range.bam > ${TRDIR}/tmp/temp.range.depth
    check_error $?
    #
    depth_ave=`awk '{total = total + $3} END{print (total / NR)}' ${TRDIR}/tmp/temp.range.depth`
    check_error $?
    #
    echo $line | awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"'${depth_ave}'"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\t"$23"\t"$24"\t"$25}' >> ${TRDIR}/tmp/juncListitd14.depth.txt
    check_error $?
  
  done < ${TRDIR}/tmp/juncListitd14.range.txt
fi

rm ${TRDIR}/tmp/temp.range.bed 
rm ${TRDIR}/tmp/juncListitd14.range.txt
rm ${TRDIR}/tmp/temp.range.bam.bai
rm ${TRDIR}/tmp/temp.range.bam
rm ${TRDIR}/tmp/temp.range.depth

#__COMMENT_OUT__
# : <<'#__COMMENT_OUT__'
if [ -s ${TRDIR}/tmp/juncListitd14.depth.txt ]; then

  #
  echo "perl ${SCRIPTDIR}/makelistBed.pl  ${TRDIR}/tmp/juncListitd14.depth.txt > ${TRDIR}/tmp/juncListitd14.bed "
  perl ${SCRIPTDIR}/makelistBed.pl  ${TRDIR}/tmp/juncListitd14.depth.txt > ${TRDIR}/tmp/juncListitd14.bed 
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.exon.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u  > ${TRDIR}/tmp/refGene.merged.coding.exon.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.exon.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u  > ${TRDIR}/tmp/refGene.merged.coding.exon.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.exon.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.exon.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.exon.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.exon.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.intron.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.coding.intron.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.intron.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.coding.intron.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.intron.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.intron.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.intron.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.intron.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.5putr.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.coding.5putr.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.5putr.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.coding.5putr.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.5putr.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.5putr.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.5putr.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.5putr.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.3putr.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.coding.3putr.anno.bed "
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.3putr.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.coding.3putr.anno.bed 
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.3putr.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.3putr.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.coding.3putr.anno.bed > ${TRDIR}/tmp/refGene.merged.coding.3putr.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.noncoding.exon.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.noncoding.exon.anno.bed "
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.noncoding.exon.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.noncoding.exon.anno.bed 
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.noncoding.exon.anno.bed > ${TRDIR}/tmp/refGene.merged.noncoding.exon.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.noncoding.exon.anno.bed > ${TRDIR}/tmp/refGene.merged.noncoding.exon.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.noncoding.intron.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.noncoding.intron.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.noncoding.intron.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/refGene.merged.noncoding.intron.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.noncoding.intron.anno.bed > ${TRDIR}/tmp/refGene.merged.noncoding.intron.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/refGene.merged.noncoding.intron.anno.bed > ${TRDIR}/tmp/refGene.merged.noncoding.intron.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/ensGene.merged.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/ensGene.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/ensGene.merged.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/ensGene.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/ensGene.anno.bed > ${TRDIR}/tmp/ensGene.anno.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/ensGene.anno.bed > ${TRDIR}/tmp/ensGene.anno.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/knownGene.merged.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/kownGene.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/knownGene.merged.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/kownGene.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/kownGene.anno.bed > ${TRDIR}/tmp/kownGene.anno.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/kownGene.anno.bed > ${TRDIR}/tmp/kownGene.anno.merge.bed
  check_error $?
  #
  echo "${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/simpleRepeat.merged.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/simpleRepeat.anno.bed"
  ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/simpleRepeat.merged.bed -b ${TRDIR}/tmp/juncListitd14.bed -wa | sort -u > ${TRDIR}/tmp/simpleRepeat.anno.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/simpleRepeat.anno.bed > ${TRDIR}/tmp/simpleRepeat.anno.merge.bed"
  perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/tmp/simpleRepeat.anno.bed > ${TRDIR}/tmp/simpleRepeat.anno.merge.bed
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/addGeneAnno2.pl  ${TRDIR}/tmp/juncListitd14.depth.txt ${TRDIR}/tmp/refGene.merged.coding.exon.merge.bed ${TRDIR}/tmp/refGene.merged.coding.intron.merge.bed ${TRDIR}/tmp/refGene.merged.coding.5putr.merge.bed ${TRDIR}/tmp/refGene.merged.coding.3putr.merge.bed ${TRDIR}/tmp/refGene.merged.noncoding.exon.merge.bed ${TRDIR}/tmp/refGene.merged.noncoding.intron.merge.bed ${TRDIR}/tmp/ensGene.anno.merge.bed ${TRDIR}/tmp/kownGene.anno.merge.bed ${TRDIR}/tmp/simpleRepeat.anno.merge.bed > ${TRDIR}/tmp/juncListitd15.list "
  perl ${SCRIPTDIR}/addGeneAnno2.pl  ${TRDIR}/tmp/juncListitd14.depth.txt ${TRDIR}/tmp/refGene.merged.coding.exon.merge.bed ${TRDIR}/tmp/refGene.merged.coding.intron.merge.bed ${TRDIR}/tmp/refGene.merged.coding.5putr.merge.bed ${TRDIR}/tmp/refGene.merged.coding.3putr.merge.bed ${TRDIR}/tmp/refGene.merged.noncoding.exon.merge.bed ${TRDIR}/tmp/refGene.merged.noncoding.intron.merge.bed ${TRDIR}/tmp/ensGene.anno.merge.bed ${TRDIR}/tmp/kownGene.anno.merge.bed ${TRDIR}/tmp/simpleRepeat.anno.merge.bed > ${TRDIR}/tmp/juncListitd15.list 
  check_error $?

else
  /bin/echo -n > ${TRDIR}/tmp/juncListitd15.list
  check_error $?
fi

rm ${TRDIR}/tmp/refGene.merged.coding.exon.merge.bed
rm ${TRDIR}/tmp/refGene.merged.coding.exon.anno.bed
rm ${TRDIR}/tmp/refGene.merged.coding.intron.merge.bed
rm ${TRDIR}/tmp/refGene.merged.coding.intron.anno.bed
rm ${TRDIR}/tmp/refGene.merged.coding.5putr.merge.bed
rm ${TRDIR}/tmp/refGene.merged.coding.5putr.anno.bed
rm ${TRDIR}/tmp/refGene.merged.noncoding.exon.merge.bed
rm ${TRDIR}/tmp/refGene.merged.noncoding.exon.anno.bed
rm ${TRDIR}/tmp/refGene.merged.coding.3putr.merge.bed
rm ${TRDIR}/tmp/refGene.merged.coding.3putr.anno.bed
rm ${TRDIR}/tmp/refGene.merged.noncoding.intron.merge.bed
rm ${TRDIR}/tmp/refGene.merged.noncoding.intron.anno.bed
rm ${TRDIR}/tmp/ensGene.anno.merge.bed
rm ${TRDIR}/tmp/ensGene.anno.bed
rm ${TRDIR}/tmp/kownGene.anno.merge.bed
rm ${TRDIR}/tmp/kownGene.anno.bed
rm ${TRDIR}/tmp/simpleRepeat.anno.merge.bed
rm ${TRDIR}/tmp/simpleRepeat.anno.bed
#__COMMENT_OUT__

# : <<'#__COMMENT_OUT__'
if [ -s ${TRDIR}/tmp/juncListitd15.list ]; then

  # inhouse itd (itd-bps range) annotation
  if [ ! -s ${INHOUSEDIR}/normal_inhouse_itd.list ]; then
    /bin/echo -n > ${INHOUSEDIR}/normal_inhouse_itd.list
    check_error $?
  fi
  #
  echo "perl ${SCRIPTDIR}/normalITDbedmaker2.pl ${INHOUSEDIR}/normal_inhouse_itd.list > ${TRDIR}/tmp/tmp.inhouse.txt"
  perl ${SCRIPTDIR}/normalITDbedmaker2.pl ${INHOUSEDIR}/normal_inhouse_itd.list > ${TRDIR}/tmp/tmp.inhouse.txt
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makelistBed3.pl ${TRDIR}/tmp/juncListitd15.list ${TRDIR}/tmp/tmp.inhouse.txt $SAMPLE_NAME > ${TRDIR}/tmp/juncListitd16.list"
  perl ${SCRIPTDIR}/makelistBed3.pl ${TRDIR}/tmp/juncListitd15.list ${TRDIR}/tmp/tmp.inhouse.txt $SAMPLE_NAME > ${TRDIR}/tmp/juncListitd16.list
  check_error $?
  
  # inhouse itd-bp annotation
  if [ ! -s ${INHOUSEDIR}/normal_inhouse_breakpoint.list ]; then
    /bin/echo -n > ${INHOUSEDIR}/normal_inhouse_breakpoint.list
  fi 
  #
  echo "perl ${SCRIPTDIR}/normalBPbedmaker.pl ${INHOUSEDIR}/normal_inhouse_breakpoint.list ${TRDIR}/tmp/tmp.bp.left.txt ${TRDIR}/tmp/tmp.bp.right.txt $SAMPLE_NAME"
  perl ${SCRIPTDIR}/normalBPbedmaker.pl ${INHOUSEDIR}/normal_inhouse_breakpoint.list ${TRDIR}/tmp/tmp.bp.left.txt ${TRDIR}/tmp/tmp.bp.right.txt $SAMPLE_NAME
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/makelistBed2.pl ${TRDIR}/tmp/juncListitd16.list ${TRDIR}/tmp/juncListitd16_left.txt ${TRDIR}/tmp/juncListitd16_right.txt"
  perl ${SCRIPTDIR}/makelistBed2.pl ${TRDIR}/tmp/juncListitd16.list ${TRDIR}/tmp/juncListitd16_left.txt ${TRDIR}/tmp/juncListitd16_right.txt
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/mergeInhouse32.pl ${TRDIR}/tmp/juncListitd16_left.txt ${TRDIR}/tmp/tmp.bp.left.txt > ${TRDIR}/tmp/juncListitd16.inhouse.1.txt"
  perl ${SCRIPTDIR}/mergeInhouse32.pl ${TRDIR}/tmp/juncListitd16_left.txt ${TRDIR}/tmp/tmp.bp.left.txt > ${TRDIR}/tmp/juncListitd16.inhouse.1.txt
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/mergeInhouse32.pl ${TRDIR}/tmp/juncListitd16_right.txt ${TRDIR}/tmp/tmp.bp.right.txt > ${TRDIR}/tmp/juncListitd16.inhouse.2.txt"
  perl ${SCRIPTDIR}/mergeInhouse32.pl ${TRDIR}/tmp/juncListitd16_right.txt ${TRDIR}/tmp/tmp.bp.right.txt > ${TRDIR}/tmp/juncListitd16.inhouse.2.txt
  check_error $?
  #
  echo "perl ${SCRIPTDIR}/mergeInhouse33.pl ${TRDIR}/tmp/juncListitd16.list ${TRDIR}/tmp/juncListitd16.inhouse.1.txt ${TRDIR}/tmp/juncListitd16.inhouse.2.txt > ${TRDIR}/tmp/juncListitd17.list"
  perl ${SCRIPTDIR}/mergeInhouse33.pl ${TRDIR}/tmp/juncListitd16.list ${TRDIR}/tmp/juncListitd16.inhouse.1.txt ${TRDIR}/tmp/juncListitd16.inhouse.2.txt > ${TRDIR}/tmp/juncListitd17.list
  check_error $?
  #
else
  /bin/echo -n > ${TRDIR}/tmp/juncListitd17.list
  check_error $?
fi

#
echo "perl ${SCRIPTDIR}/makeITDBed3.pl ${TRDIR}/tmp/juncListitd15.list $SAMPLE_NAME > ${TRDIR}/inhouse_itd.tsv"
perl ${SCRIPTDIR}/makeITDBed3.pl ${TRDIR}/tmp/juncListitd15.list $SAMPLE_NAME > ${TRDIR}/inhouse_itd.tsv
check_error $?
#
echo "cp ${TRDIR}/tmp/juncListitd17.list ${TRDIR}/itd_list.tsv"
cp ${TRDIR}/tmp/juncListitd17.list ${TRDIR}/itd_list.tsv
check_error $?

rm ${TRDIR}/tmp/tmp.inhouse.txt
rm ${TRDIR}/tmp/tmp.bp.right.txt
rm ${TRDIR}/tmp/tmp.bp.left.txt
rm ${TRDIR}/tmp/juncListitd16_right.txt
rm ${TRDIR}/tmp/juncListitd16.list
rm ${TRDIR}/tmp/juncListitd16_left.txt
rm ${TRDIR}/tmp/juncListitd16.inhouse.1.txt
rm ${TRDIR}/tmp/juncListitd17.list
rm ${TRDIR}/tmp/juncListitd16.inhouse.2.txt
#__COMMENT_OUT__

echo "***** [$0] end " `date +'%Y/%m/%d %H:%M:%S'` " *****"

