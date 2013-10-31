# /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l s_vmem=8G,mem_req=8
#$ -e log 
#$ -o log 

only_annotation=0
# : <<'#__COMMENT_OUT__'
write_usage() {
  echo ""
  echo "Usage: `basename $0` [option -a] <path to the target bam file> <path to the output directory> <sample name>"
  echo ""
}

while getopts a opt; do
  case $opt in
    a) only_annotation=1
    ;;
    *) write_usage
    exit 1
    ;;
  esac
done
shift `expr $OPTIND - 1`
#__COMMENT_OUT__

readonly DIR=`dirname ${0}`
readonly INPUTBAM=$1
readonly TRDIR=$2
readonly SAMPLE_NAME=$3
itd_env=$4

# : <<'#__COMMENT_OUT__'
if [ $# -le 2 -o $# -ge 5 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi
#__COMMENT_OUT__

if [ $# -eq 3 ]; then
  conf_dir=`echo $(cd ${DIR} && pwd)`
  itd_env=${DIR}/config.env
else
  conf_dir=`dirname ${itd_env}`
  conf_dir=`echo $(cd ${conf_dir} && pwd)`
  conf_file="${itd_env##*/}"
  itd_env=${conf_dir}/${conf_file}
fi

# : <<'#__COMMENT_OUT__'
if [ ! -f ${itd_env} ]; then
  echo "${itd_env} does not exists."
  write_usage
  exit 1
fi
#__COMMENT_OUT__

script_main_dir=`echo $(cd ${DIR} && pwd)`
readonly SCRIPTDIR=${script_main_dir}/subscripts
readonly DBDIR=${script_main_dir}/db
readonly INHOUSEDIR=${script_main_dir}/inhouse
readonly UTIL=${SCRIPTDIR}/utility.sh

# : <<'#__COMMENT_OUT__'
if [ ! -f ${UTIL} ]; then
  echo "${UTIL} does not exists."
  write_usage
  exit 1
fi
#__COMMENT_OUT__

source ${itd_env}
source ${UTIL}

check_file_exists $INPUTBAM
check_mkdir $TRDIR

if [ $only_annotation -eq 0 ]; then
  echo "Step1. Search ITD Break Point."
  date

# : <<'#__COMMENT_OUT__'
  ${PATH_TO_SAMTOOLS}/samtools view -h -F 1292 ${INPUTBAM} > ${TRDIR}/temp.input.sam
  check_error $?
  perl ${SCRIPTDIR}/getCandJunc.pl ${TRDIR}/temp.input.sam 10 20 > ${TRDIR}/candJunc.fa
  check_error $?
  ${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -minScore=20 -ooc=${PATH_TO_BLAT_OOC} ${PATH_TO_BLAT_REF} ${TRDIR}/candJunc.fa ${TRDIR}/candJunc.psl
  check_error $?
  perl ${SCRIPTDIR}/psl2junction2.pl ${TRDIR}/candJunc.psl ${TRDIR}/candJunc.txt ${TRDIR}/junc2ID.txt
  check_error $?
  perl ${SCRIPTDIR}/makeBeds2.pl ${TRDIR}/candJunc.txt ${TRDIR}/cj_tmp11_0.bed ${TRDIR}/cj_tmp12_0.bed ${TRDIR}/cj_tmp21_0.bed ${TRDIR}/cj_tmp22_0.bed 10
  check_error $?

  if [ -s ${TRDIR}/cj_tmp22_0.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${TRDIR}/cj_tmp11_0.bed -b ${TRDIR}/cj_tmp22_0.bed -wb > ${TRDIR}/candJunc.inter1_0.txt
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/candJunc.inter1_0.txt
    check_error $?
  fi
  if [ -s ${TRDIR}/cj_tmp21_0.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${TRDIR}/cj_tmp12_0.bed -b ${TRDIR}/cj_tmp21_0.bed -wb > ${TRDIR}/candJunc.inter2_0.txt
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/candJunc.inter2_0.txt
    check_error $?
  fi

  perl ${SCRIPTDIR}/mergeJunc22.pl ${TRDIR}/candJunc.inter1_0.txt ${TRDIR}/candJunc.inter2_0.txt 10 > ${TRDIR}/juncList12.txt
  check_error $?
  perl ${SCRIPTDIR}/filterLowSclip.pl ${TRDIR}/juncList12.txt 1 ${TRDIR}/juncList12.txt.filt
  check_error $?
  perl ${SCRIPTDIR}/filterShortITD.pl ${TRDIR}/juncList12.txt.filt 10 300 ${TRDIR}/juncList12.txt.filt2
  check_error $?
  perl ${SCRIPTDIR}/mergeSameData.pl ${TRDIR}/juncList12.txt.filt2 > ${TRDIR}/juncList12.txt.merge
  check_error $?
  perl ${SCRIPTDIR}/mergeSameData2.pl ${TRDIR}/juncList12.txt.merge > ${TRDIR}/juncList12.txt.merge2
  check_error $?
  perl ${SCRIPTDIR}/makeRef2.pl ${TRDIR}/juncList12.txt.merge2 ${TRDIR}/juncList12.ref.bed
  check_error $?
  perl ${SCRIPTDIR}/makeTargetIdSam.pl ${TRDIR}/juncList12.txt.merge2 ${TRDIR}/temp.input.sam > ${TRDIR}/targetId.sam
  check_error $?

  if [ -s ${TRDIR}/juncList12.ref.bed ]; then
    ${PATH_TO_BEDTOOLS}/fastaFromBed -fi ${PATH_TO_HG19REF} -bed ${TRDIR}/juncList12.ref.bed -fo ${TRDIR}/juncList12.ref.fasta -name -tab
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/juncList12.ref.fasta
    check_error $?
  fi

  perl ${SCRIPTDIR}/addRef2.pl ${TRDIR}/juncList12.txt.merge2 ${TRDIR}/juncList12.ref.fasta ${TRDIR}/juncList12.ref.txt
  check_error $?

  rm ${TRDIR}/temp.input.sam
  rm ${TRDIR}/candJunc.fa
  rm ${TRDIR}/candJunc.psl
  rm ${TRDIR}/junc2ID.txt
#__COMMENT_OUT__

  echo "Step2. Assemble Secence Data."
  date
# : <<'#__COMMENT_OUT__'

  /bin/echo -n > ${TRDIR}/itdContig.fa
  check_error $?
  /bin/echo -n > ${TRDIR}/itdContig.list
  check_error $?

  count=1
  while read line; do
    idseq1=`echo "$line" | cut -f 7`
    idseq2=`echo "$line" | cut -f 8`
    itdrefleft=`echo "$line" | cut -f 12`
    itdrefright=`echo "$line" | cut -f 13`
    itdrefleftlong=`echo "$line" | cut -f 14`
    itdrefrightlong=`echo "$line" | cut -f 15`
    itdrefcenter=`echo "$line" | cut -f 16`
    itdref=${itdrefleft}${itdrefcenter}${itdrefcenter}${itdrefright}
    idseq="${idseq1},${idseq2}"

    echo $idseq > ${TRDIR}/idseq.txt 
    check_error $?
    perl ${SCRIPTDIR}/makeCap3fa.pl ${TRDIR}/idseq.txt ${TRDIR}/targetId.sam ${TRDIR}/temp.cap3.fa
    check_error $?
    ${PATH_TO_CAP3}/cap3 ${TRDIR}/temp.cap3.fa -j 31 -o 16 -s 251 -p 66 -i 21 > ${TRDIR}/temp.cap3.contig
    check_error $?
  
    chkflg=`perl ${SCRIPTDIR}/checkMultiContigs.pl ${TRDIR}/temp.cap3.fa.cap.contigs`
    check_error $?
  
    targetContig="Contig1"
    if [ $chkflg -eq 1 ]; then
      chkflg=`perl ${SCRIPTDIR}/mergeCap3Contigs.pl ${TRDIR}/temp.cap3.fa.cap.contigs`
      check_error $?
    fi
  
    if [ $chkflg -ge 1 ]; then
      echo '>'query > ${TRDIR}/temp.fasta36.fa 
      echo $itdref >> ${TRDIR}/temp.fasta36.fa 
      ${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/temp.fasta36.fa ${TRDIR}/temp.cap3.fa.cap.contigs > ${TRDIR}/temp.fasta36.fa.contigs.fastaTabular
      check_error $?
      targetContig=`perl ${SCRIPTDIR}/targetContig11.pl ${TRDIR}/temp.fasta36.fa.contigs.fastaTabular`
      check_error $?
    fi
  
    contigSeq=""
    new_contigSeq=""
    if [ ${#targetContig} -gt 0 ]; then
      contigSeq=`perl ${SCRIPTDIR}/contigGetter11.pl $targetContig ${TRDIR}/temp.cap3.fa.cap.contigs`
      check_error $?
    fi
  
    if [ ${#contigSeq} -gt 0 ]; then
      echo '>'$count >> ${TRDIR}/itdContig.fa 
      echo $contigSeq  >> ${TRDIR}/itdContig.fa 
    fi
    echo -e "$line\t$contigSeq" >> ${TRDIR}/itdContig.list
  
    count=$((count+1))
  done < ${TRDIR}/juncList12.ref.txt

  if [ -s ${TRDIR}/itdContig.fa ]; then
    ${PATH_TO_BLAT}/blat -stepSize=5 -repMatch=2253 -maxIntron=1000 ${PATH_TO_BLAT_REF} ${TRDIR}/itdContig.fa ${TRDIR}/itdContig.psl
    check_error $?
  else 
    /bin/echo -n > ${TRDIR}/itdContig.psl
    check_error $?
  fi
  perl ${SCRIPTDIR}/psl2itdcontig.pl ${TRDIR}/itdContig.psl ${TRDIR}/itdContig.list 10 ${TRDIR}/juncListitd12.txt
  check_error $?

#__COMMENT_OUT__
  echo "Step3. Check Assembled Contigs."
  date

# : <<'#__COMMENT_OUT__'
  /bin/echo -n > ${TRDIR}/juncListitd13.txt
  check_error $?

  while read line; do
    itdseqref1=`echo "$line" | cut -f 10`  # ITD-BP Reference 1
    itdseqref2=`echo "$line" | cut -f 11`  # ITD-BP Reference 2
    itdseq=`echo "$line" | cut -f 18`      # ITD candidate sequence
    itdstart=`echo "$line" | cut -f 20`    # ITD candidate spos
    itdend=`echo "$line" | cut -f 21`      # ITD candidate epos
    
    if [ "${itdseq-UNDEF}" != "UNDEF" ]; then
      if [ "${itdseq}" != "" ]; then
        itdseqlen=${#itdseq}
        echo '>'itdseqref1 > ${TRDIR}/temp.fasta36.itdseqref1.fa
        check_error $?
        echo $itdseqref1 >> ${TRDIR}/temp.fasta36.itdseqref1.fa 
        check_error $?
        echo '>'itdseqref2 > ${TRDIR}/temp.fasta36.itdseqref2.fa 
        check_error $?
        echo $itdseqref2 >> ${TRDIR}/temp.fasta36.itdseqref2.fa 
        check_error $?
        echo '>'itdseq > ${TRDIR}/temp.fasta36.itdseq1.fa 
        check_error $?

        if [ $itdseqlen -gt ${#itdseqref1} ]; then
          if [ $itdstart -eq 0 ]; then
            echo $itdseq | cut -c `expr $itdseqlen + 1 - ${#itdseqref1}`-  >> ${TRDIR}/temp.fasta36.itdseq1.fa 
            check_error $?
          elif [ $itdend -eq 0 ]; then
            echo $itdseq | cut -c  -${#itdseqref1} >> ${TRDIR}/temp.fasta36.itdseq1.fa 
            check_error $?
          else
            echo $itdseq >> ${TRDIR}/temp.fasta36.itdseq1.fa
            check_error $?
          fi
        else
          echo $itdseq >> ${TRDIR}/temp.fasta36.itdseq1.fa
          check_error $?
        fi
   
        echo '>'itdseq > ${TRDIR}/temp.fasta36.itdseq2.fa 
        check_error $?
        if [ $itdseqlen -gt ${#itdseqref2} ]; then
          if [ $itdstart -eq 0 ]; then
            echo $itdseq | cut -c `expr $itdseqlen + 1 - ${#itdseqref2}`-  >> ${TRDIR}/temp.fasta36.itdseq2.fa 
            check_error $?
          elif [ $itdend -eq 0 ]; then
            echo $itdseq | cut -c  -${#itdseqref2} >> ${TRDIR}/temp.fasta36.itdseq2.fa 
            check_error $?
          else
            echo $itdseq >> ${TRDIR}/temp.fasta36.itdseq2.fa
            check_error $?
          fi
        else
          echo $itdseq >> ${TRDIR}/temp.fasta36.itdseq2.fa
          check_error $?
        fi
    
        ${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/temp.fasta36.itdseq1.fa ${TRDIR}/temp.fasta36.itdseqref1.fa > ${TRDIR}/temp.fasta36.itdseqfef1.fastaTabular
        check_error $?
        alignmentlen1=`perl ${SCRIPTDIR}/targetContig12.pl ${TRDIR}/temp.fasta36.itdseqfef1.fastaTabular`
        check_error $?
        ${PATH_TO_FASTA}/fasta36 -d 1 -m 8 -b 1 ${TRDIR}/temp.fasta36.itdseq2.fa ${TRDIR}/temp.fasta36.itdseqref2.fa > ${TRDIR}/temp.fasta36.itdseqfef2.fastaTabular
        check_error $?
        alignmentlen2=`perl ${SCRIPTDIR}/targetContig12.pl ${TRDIR}/temp.fasta36.itdseqfef2.fastaTabular`
        check_error $?
        echo -e "${line}\t${alignmentlen1}\t${alignmentlen2}" >> ${TRDIR}/juncListitd13.txt
        check_error $?
      fi
    fi
  done < ${TRDIR}/juncListitd12.txt

  perl ${SCRIPTDIR}/itddetect.pl ${TRDIR}/juncListitd13.txt ${TRDIR}/juncListitd14.txt
  check_error $?
  mv ${TRDIR}/juncListitd14.txt ${TRDIR}/itd_list_non_inhouse.tsv
#__COMMENT_OUT__

fi 
echo "Step4. Annotate."
date

#  : <<'#__COMMENT_OUT__'
/bin/echo -n > ${TRDIR}/juncListitd14.depth.txt
check_error $?

if [ -s ${TRDIR}/itd_list_non_inhouse.tsv ]; then

  perl ${SCRIPTDIR}/addJunctionPosition.pl ${TRDIR}/itd_list_non_inhouse.tsv > ${TRDIR}/juncListitd14.range.txt
  check_error $?

  while read line; do
    junc_chr=`echo "$line" | cut -f 1`
    junc_start=`echo "$line" | cut -f 2`
    junc_end=`echo "$line" | cut -f 3`
    range=${junc_chr}":"${junc_start}"-"${junc_end}

    ${PATH_TO_SAMTOOLS}/samtools view -h -b -F 1036 ${INPUTBAM} ${range} > ${TRDIR}/temp.range.bam
    
    ${PATH_TO_SAMTOOLS}/samtools index ${TRDIR}/temp.range.bam
    check_error $?
    echo -e "${junc_chr}\t${junc_start}\t${junc_end}" > ${TRDIR}/temp.range.bed
    check_error $?
    ${PATH_TO_SAMTOOLS}/samtools depth -b ${TRDIR}/temp.range.bed ${TRDIR}/temp.range.bam > ${TRDIR}/temp.range.depth
    check_error $?
    depth_ave=`awk '{total = total + $3} END{print (total / NR)}' ${TRDIR}/temp.range.depth`
    check_error $?
    echo $line | awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"'${depth_ave}'"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\t"$23"\t"$24"\t"$25}' >> ${TRDIR}/juncListitd14.depth.txt
    check_error $?
  
  done < ${TRDIR}/juncListitd14.range.txt
fi

#__COMMENT_OUT__
# : <<'#__COMMENT_OUT__'
if [ -s ${TRDIR}/juncListitd14.depth.txt ]; then

  perl ${SCRIPTDIR}/makelistBed.pl  ${TRDIR}/juncListitd14.depth.txt > ${TRDIR}/juncListitd14.bed 
  check_error $?

  if [ -f ${DBDIR}/refGene.merged.coding.exon.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.exon.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/refGene.merged.coding.exon.anno.bed
    check_error $?
    sort -u ${TRDIR}/refGene.merged.coding.exon.anno.bed > ${TRDIR}/refGene.merged.coding.exon.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/refGene.merged.coding.exon.sort.bed > ${TRDIR}/refGene.merged.coding.exon.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/refGene.merged.coding.exon.merge.bed
    check_error $?
  fi
  if [ -f ${DBDIR}/refGene.merged.coding.intron.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.intron.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/refGene.merged.coding.intron.anno.bed
    check_error $?
    sort -u ${TRDIR}/refGene.merged.coding.intron.anno.bed > ${TRDIR}/refGene.merged.coding.intron.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/refGene.merged.coding.intron.sort.bed > ${TRDIR}/refGene.merged.coding.intron.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/refGene.merged.coding.intron.merge.bed 
    check_error $?
  fi
  if [ -f ${DBDIR}/refGene.merged.coding.5putr.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.5putr.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/refGene.merged.coding.5putr.anno.bed
    check_error $?
    sort -u ${TRDIR}/refGene.merged.coding.5putr.anno.bed > ${TRDIR}/refGene.merged.coding.5putr.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/refGene.merged.coding.5putr.sort.bed > ${TRDIR}/refGene.merged.coding.5putr.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/refGene.merged.coding.5putr.merge.bed
    check_error $?
  fi
  if [ -f ${DBDIR}/refGene.merged.coding.3putr.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.coding.3putr.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/refGene.merged.coding.3putr.anno.bed 
    check_error $?
    sort -u ${TRDIR}/refGene.merged.coding.3putr.anno.bed > ${TRDIR}/refGene.merged.coding.3putr.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/refGene.merged.coding.3putr.sort.bed > ${TRDIR}/refGene.merged.coding.3putr.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/refGene.merged.coding.3putr.merge.bed
    check_error $?
  fi 
  if [ -f ${DBDIR}/refGene.merged.noncoding.exon.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.noncoding.exon.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/refGene.merged.noncoding.exon.anno.bed 
    check_error $?
    sort -u ${TRDIR}/refGene.merged.noncoding.exon.anno.bed > ${TRDIR}/refGene.merged.noncoding.exon.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/refGene.merged.noncoding.exon.sort.bed > ${TRDIR}/refGene.merged.noncoding.exon.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/refGene.merged.noncoding.exon.merge.bed
    check_error $?
  fi
  if [ -f ${DBDIR}/refGene.merged.noncoding.intron.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/refGene.merged.noncoding.intron.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/refGene.merged.noncoding.intron.anno.bed
    check_error $?
    sort -u ${TRDIR}/refGene.merged.noncoding.intron.anno.bed > ${TRDIR}/refGene.merged.noncoding.intron.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/refGene.merged.noncoding.intron.sort.bed > ${TRDIR}/refGene.merged.noncoding.intron.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/refGene.merged.noncoding.intron.merge.bed
    check_error $?
  fi
  if [ -f ${DBDIR}/gene.ens.sort.bed ]; then 
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/gene.ens.sort.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/gene.ens.anno.bed
    check_error $?
    sort -u ${TRDIR}/gene.ens.anno.bed > ${TRDIR}/gene.ens.anno.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/gene.ens.anno.sort.bed > ${TRDIR}/gene.ens.anno.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/gene.ens.anno.merge.bed
    check_error $?
  fi
  if [ -f ${DBDIR}/gene.known.sort.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/gene.known.sort.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/gene.known.anno.bed
    check_error $?
    sort -u ${TRDIR}/gene.known.anno.bed > ${TRDIR}/gene.known.anno.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/gene.known.anno.sort.bed > ${TRDIR}/gene.known.anno.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/gene.known.anno.merge.bed
    check_error $?
  fi
  if [ -f ${DBDIR}/gene.repeat.sort.bed ]; then
    ${PATH_TO_BEDTOOLS}/intersectBed -a ${DBDIR}/gene.repeat.sort.bed -b ${TRDIR}/juncListitd14.bed -wa > ${TRDIR}/gene.repeat.anno.bed
    check_error $?
    sort -u ${TRDIR}/gene.repeat.anno.bed > ${TRDIR}/gene.repeat.anno.sort.bed
    check_error $?
    perl ${SCRIPTDIR}/makeJuncToGene.pl ${TRDIR}/gene.repeat.anno.sort.bed > ${TRDIR}/gene.repeat.anno.merge.bed
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/gene.repeat.anno.merge.bed
    check_error $?
  fi

  perl ${SCRIPTDIR}/addGeneAnno2.pl  ${TRDIR}/juncListitd14.depth.txt ${TRDIR}/refGene.merged.coding.exon.merge.bed ${TRDIR}/refGene.merged.coding.intron.merge.bed ${TRDIR}/refGene.merged.coding.5putr.merge.bed ${TRDIR}/refGene.merged.coding.3putr.merge.bed ${TRDIR}/refGene.merged.noncoding.exon.merge.bed ${TRDIR}/refGene.merged.noncoding.intron.merge.bed ${TRDIR}/gene.ens.anno.merge.bed ${TRDIR}/gene.known.anno.merge.bed ${TRDIR}/gene.repeat.anno.merge.bed > ${TRDIR}/juncListitd15.list 
  check_error $?

else
  /bin/echo -n > ${TRDIR}/juncListitd15.list
  check_error $?
fi
#__COMMENT_OUT__

# : <<'#__COMMENT_OUT__'
if [ -s ${TRDIR}/juncListitd15.list ]; then

  # inhouse itd (itd-bps range) annotation
  if [ ! -s ${INHOUSEDIR}/normal_inhouse_itd.list ]; then
    /bin/echo -n > ${INHOUSEDIR}/normal_inhouse_itd.list
    check_error $?
  fi
  perl ${SCRIPTDIR}/normalITDbedmaker2.pl ${INHOUSEDIR}/normal_inhouse_itd.list > ${TRDIR}/tmp.inhouse.txt
  check_error $?
  perl ${SCRIPTDIR}/makelistBed3.pl ${TRDIR}/juncListitd15.list ${TRDIR}/tmp.inhouse.txt $SAMPLE_NAME > ${TRDIR}/juncListitd16.list
  check_error $?
  
  # inhouse itd-bp annotation
  if [ ! -s ${INHOUSEDIR}/normal_inhouse_breakpoint.list ]; then
    /bin/echo -n > ${INHOUSEDIR}/normal_inhouse_breakpoint.list
  fi 
  perl ${SCRIPTDIR}/normalBPbedmaker.pl ${INHOUSEDIR}/normal_inhouse_breakpoint.list ${TRDIR}/tmp.bp.left.txt ${TRDIR}/tmp.bp.right.txt $SAMPLE_NAME
  check_error $?
  perl ${SCRIPTDIR}/makelistBed2.pl ${TRDIR}/juncListitd16.list ${TRDIR}/juncListitd16_1.txt ${TRDIR}/juncListitd16_2.txt
  check_error $?
  if [ -s ${TRDIR}/tmp.bp.left.txt ]; then
    perl ${SCRIPTDIR}/mergeInhouse32.pl ${TRDIR}/juncListitd16_1.txt ${TRDIR}/tmp.bp.left.txt > ${TRDIR}/juncListitd16.inhouse.1.txt
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/juncListitd16.inhouse.1.txt
    check_error $?
  fi
  if [ -s ${TRDIR}/tmp.bp.right.txt ]; then
    perl ${SCRIPTDIR}/mergeInhouse32.pl ${TRDIR}/juncListitd16_2.txt ${TRDIR}/tmp.bp.right.txt > ${TRDIR}/juncListitd16.inhouse.2.txt
    check_error $?
  else
    /bin/echo -n > ${TRDIR}/juncListitd16.inhouse.2.txt
    check_error $?
  fi
  perl ${SCRIPTDIR}/mergeInhouse33.pl ${TRDIR}/juncListitd16.list ${TRDIR}/juncListitd16.inhouse.1.txt ${TRDIR}/juncListitd16.inhouse.2.txt > ${TRDIR}/juncListitd17.list
  check_error $?
else
  /bin/echo -n > ${TRDIR}/juncListitd17.list
  check_error $?
fi

perl ${SCRIPTDIR}/makeITDBed3.pl ${TRDIR}/juncListitd15.list $SAMPLE_NAME > ${TRDIR}/inhouse_itd.tsv
check_error $?
perl ${SCRIPTDIR}/makeJunctionBed2.pl ${TRDIR}/candJunc.txt $SAMPLE_NAME > ${TRDIR}/inhouse_breakpoint.tsv
check_error $?
cat ${SCRIPTDIR}/header.txt > ${TRDIR}/itd_list.tsv
cat ${TRDIR}/juncListitd17.list >> ${TRDIR}/itd_list.tsv
check_error $?
#__COMMENT_OUT__


rm -f ${TRDIR}/cj_tmp11_0.bed
rm -f ${TRDIR}/cj_tmp12_0.bed
rm -f ${TRDIR}/cj_tmp21_0.bed
rm -f ${TRDIR}/cj_tmp22_0.bed
rm -f ${TRDIR}/candJunc.inter1_0.txt
rm -f ${TRDIR}/candJunc.inter2_0.txt
rm -f ${TRDIR}/gene.ens.anno.bed
rm -f ${TRDIR}/gene.ens.anno.merge.bed
rm -f ${TRDIR}/gene.ens.anno.sort.bed
rm -f ${TRDIR}/gene.known.anno.bed
rm -f ${TRDIR}/gene.known.anno.merge.bed
rm -f ${TRDIR}/gene.known.anno.sort.bed
rm -f ${TRDIR}/gene.repeat.anno.merge.bed
rm -f ${TRDIR}/idseq.txt
rm -f ${TRDIR}/itdContig.fa
rm -f ${TRDIR}/itdContig.list
rm -f ${TRDIR}/itdContig.psl
rm -f ${TRDIR}/juncList12.ref.bed
rm -f ${TRDIR}/juncList12.ref.fasta
rm -f ${TRDIR}/juncList12.ref.txt
rm -f ${TRDIR}/juncList12.txt
rm -f ${TRDIR}/juncList12.txt.filt
rm -f ${TRDIR}/juncList12.txt.filt2
rm -f ${TRDIR}/juncList12.txt.merge
rm -f ${TRDIR}/juncList12.txt.merge2
rm -f ${TRDIR}/juncListitd12.txt
rm -f ${TRDIR}/juncListitd13.txt
rm -f ${TRDIR}/juncListitd14.bed
rm -f ${TRDIR}/juncListitd15.bed
rm -f ${TRDIR}/juncListitd15.inhouse.bed
rm -f ${TRDIR}/juncListitd16_1.bed
rm -f ${TRDIR}/juncListitd16_2.bed
rm -f ${TRDIR}/juncListitd16.inhouse.1.bed
rm -f ${TRDIR}/juncListitd16.inhouse.2.bed
rm -f ${TRDIR}/juncListitd16.list
rm -f ${TRDIR}/juncListitd16_1.txt
rm -f ${TRDIR}/juncListitd16_2.txt
rm -f ${TRDIR}/juncListitd16.inhouse.1.txt
rm -f ${TRDIR}/juncListitd16.inhouse.2.txt
rm -f ${TRDIR}/juncListitd17.list
rm -f ${TRDIR}/tmp.bp.left.txt
rm -f ${TRDIR}/tmp.bp.right.txt
rm -f ${TRDIR}/tmp.inhouse.txt
rm -f ${TRDIR}/refGene.merged.coding.3putr.anno.bed
rm -f ${TRDIR}/refGene.merged.coding.3putr.merge.bed
rm -f ${TRDIR}/refGene.merged.coding.3putr.sort.bed
rm -f ${TRDIR}/refGene.merged.coding.5putr.anno.bed
rm -f ${TRDIR}/refGene.merged.coding.5putr.merge.bed
rm -f ${TRDIR}/refGene.merged.coding.5putr.sort.bed
rm -f ${TRDIR}/refGene.merged.coding.exon.anno.bed
rm -f ${TRDIR}/refGene.merged.coding.exon.merge.bed
rm -f ${TRDIR}/refGene.merged.coding.exon.sort.bed
rm -f ${TRDIR}/refGene.merged.coding.intron.anno.bed
rm -f ${TRDIR}/refGene.merged.coding.intron.merge.bed
rm -f ${TRDIR}/refGene.merged.coding.intron.sort.bed
rm -f ${TRDIR}/refGene.merged.noncoding.exon.anno.bed
rm -f ${TRDIR}/refGene.merged.noncoding.exon.merge.bed
rm -f ${TRDIR}/refGene.merged.noncoding.exon.sort.bed
rm -f ${TRDIR}/refGene.merged.noncoding.intron.anno.bed
rm -f ${TRDIR}/refGene.merged.noncoding.intron.merge.bed
rm -f ${TRDIR}/refGene.merged.noncoding.intron.sort.bed
rm -f ${TRDIR}/targetId.sam
rm -f ${TRDIR}/temp.cap3.contig
rm -f ${TRDIR}/temp.cap3.fa
rm -f ${TRDIR}/temp.cap3.fa.cap.ace
rm -f ${TRDIR}/temp.cap3.fa.cap.contigs
rm -f ${TRDIR}/temp.cap3.fa.cap.contigs.links
rm -f ${TRDIR}/temp.cap3.fa.cap.contigs.qual
rm -f ${TRDIR}/temp.cap3.fa.cap.info
rm -f ${TRDIR}/temp.cap3.fa.cap.singlets
rm -f ${TRDIR}/temp.fasta36.itdseq1.fa
rm -f ${TRDIR}/temp.fasta36.itdseq2.fa
rm -f ${TRDIR}/temp.fasta36.itdseqfef1.fastaTabular
rm -f ${TRDIR}/temp.fasta36.itdseqfef2.fastaTabular
rm -f ${TRDIR}/temp.fasta36.itdseqref1.fa
rm -f ${TRDIR}/temp.fasta36.itdseqref2.fa
rm -f ${TRDIR}/temp.range.bam
rm -f ${TRDIR}/temp.range.bam.bai
rm -f ${TRDIR}/temp.range.bed
rm -f ${TRDIR}/temp.range.depth
rm -f ${TRDIR}/tmp.inhouse.bed
rm -f ${TRDIR}/tmp.junction.bed
 : <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
exit 0

