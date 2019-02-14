#!/bin/bash 

## PIPELINE VERSION

TAG=$1
WDIR=$2
REF=$3
STRAND=$4
CPUS=$5

cd $WDIR/tr_bams 

READS=""
PARROT=""

if [[ $TAG == "" || $REF == "" || $STRAND == "" ]]
then 
  echo "ERROR: Please provide 1) output name (tag) assuming <tag>.fastq.gz or <tag>.R1.fastq.gz/<tag>.R2.fastq.gz input; 2) species/assembly alias, e.g. genprime_v23; 3) strandedness as NONE/FR/RF"
  exit 1
fi 

if [[ $STRAND == "NONE" ]]
then
  FLAG="--strandedness none"
elif [[ $STRAND == "FR" ]] 
then
  FLAG="--strandedness forward"
elif [[ $STRAND == "RF" ]]
then
  FLAG="--strandedness reverse"
else 
  echo "ERROR: you must set strand variable to either NONE, FR, or RF"
  exit
fi

TEST=`samtools view -f 0x1 $TAG.tr.bam | head`

if [[ $TEST == "" ]]
then
  echo "RSEM: processing quantification of $TAG as single-end, strandedness $STRAND ($FLAG)"
  PARROT=""
else
  echo "RSEM: processing quantification of $TAG as paired-end, strandedness $STRAND ($FLAG)"
  PARROT="--paired-end"
fi

rsem-calculate-expression -p $CPUS --bam --no-bam-output $FLAG --estimate-rspd $PARROT $TAG.tr.bam $REF $TAG > $TAG.rsem.log
