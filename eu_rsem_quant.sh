#!/bin/bash 

## PIPELINE VERSION

TAG=$1
WDIR=$2
REF=$3
STRAND=$4
CPUS=$5

cd $WDIR/tr_bams 

READS=""

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

if [[ -e $TAG.fastq.gz ]]
then
  echo "RSEM: processing quantification of $TAG as single-end, strandedness $STRAND ($FLAG)"
  READS="$TAG.fastq.gz"
elif [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  echo "RSEM: processing quantification of $TAG as paired-end, strandedness $STRAND ($FLAG)"
  READS="--paired-end $TAG.R1.fastq.gz $TAG.R2.fastq.gz"
else
  echo "ERROR: The reqiured fastq.gz files were not found!" 
  exit 1
fi

rsem-calculate-expression -p $CPUS --bam --no-bam-output $FLAG --estimate-rspd $PARROT $TAG.tr.bam $REF $TAG > $TAG.rsem.log


rsem-calculate-expression --estimate-rspd $READS $EXTREF ${TAG}.ext_rsem &> $TAG.ext_rsem.log 
rsem-calculate-expression --bowtie2 --estimate-rspd $READS $REF ${TAG}.rsem &> $TAG.rsem.log

mv $TAG.rsem.genes.results $TAG.rsem.genes.tsv
mv $TAG.rsem.isoforms.results $TAG.rsem.isoforms.tsv
