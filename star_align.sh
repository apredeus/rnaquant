#!/bin/bash 

## can be used for both single and paired-end
## archived FASTQ is assumed

TAG=$1
REFDIR=$2
SPECIES=$3
CPUS=$4

RL=""
READS=""
REF=""
WDIR=`pwd`

if [[ $TAG == "" || $SPECIES == "" || $CPUS == "" ]]
then 
  echo "ERROR: Please provide TAG, SPECIES handle, and # of CPUS!"
  exit 1
fi 

if [[ -e $TAG.fastq.gz ]]
then 
  RL=`zcat $TAG.fastq.gz | head -n 2 | tail -n 1 | wc -c | awk '{print $1-1}'`
  REF=$REFDIR/STAR/${SPECIES}_${RL}bp
  echo "Processing alignment as single-end, using STAR index $REF."
  READS=$WDIR/$TAG.fastq.gz
elif [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  RL=`zcat $TAG.R1.fastq.gz | head -n 2 | tail -n 1 | wc -c | awk '{print $1-1}'`
  REF=$REFDIR/STAR/${SPECIES}_${RL}bp
  echo "Processing alignment as paired-end, using STAR index $REF."
  READS="$WDIR/$TAG.R1.fastq.gz $WDIR/$TAG.R2.fastq.gz"
else
  echo "ERROR: The reqiured fastq.gz files were not found!" 
  exit 1
fi

if [[ ! -d $REF ]]
then 
  echo "ERROR: STAR index $REF does not exist, attempting to use default (50 bp).."
  REF=$REFDIR/STAR/${SPECIES}_50bp
  if [[ ! -d $REF ]]
  then
    echo "ERROR: No appropriate STAR reference was found!" 
    exit 1
  fi
fi

mkdir ${TAG}_STAR
cd ${TAG}_STAR
STAR --genomeDir $REF --readFilesIn $READS --runThreadN $CPUS --readFilesCommand zcat --outFilterMultimapNmax 15 --outFilterMismatchNmax 6  --outSAMstrandField All --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM 

mv Aligned.sortedByCoord.out.bam $TAG.bam
mv Aligned.toTranscriptome.out.bam $TAG.tr.bam 
mv Log.out $TAG.star_run.log 
mv Log.final.out $TAG.star_final.log

