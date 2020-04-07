#!/bin/bash 

## can be used for both single and paired-end
## archived FASTQ is assumed

TAG=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
JCPUS=$5

READS=""
REF=""
WDIR=`pwd`

if [[ $TAG == "" || $WDIR == "" || $SPECIES == "" || $REFDIR == "" || $JCPUS == "" ]]
then 
  echo "ERROR: Please provide TAG, SPECIES handle, and # of CPUS!"
  exit 1
fi 

if [[ -e $TAG.fastq.gz ]]
then 
  REF=$REFDIR/$SPECIES/$SPECIES.STAR
  echo "Processing alignment as single-end, using STAR index $REF."
  READS=$WDIR/$TAG.fastq.gz
elif [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  REF=$REFDIR/$SPECIES/$SPECIES.STAR
  echo "Processing alignment as paired-end, using STAR index $REF."
  READS="$WDIR/$TAG.R1.fastq.gz $WDIR/$TAG.R2.fastq.gz"
else
  echo "ERROR: The reqiured fastq.gz files were not found!" 
  exit 1
fi

if [[ ! -d $REF ]]
then 
  echo "ERROR: No appropriate STAR reference was found!" 
  exit 1
fi

mkdir ${TAG}_STAR
cd ${TAG}_STAR
STAR --genomeDir $REF --readFilesIn $READS --runThreadN $JCPUS --readFilesCommand zcat --outFilterMultimapNmax 15 --outFilterMismatchNmax 6  --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM &> $TAG.star_stdout.log  

mv Aligned.sortedByCoord.out.bam $TAG.bam
mv Aligned.toTranscriptome.out.bam $TAG.tr.bam 
mv Log.out $TAG.star_run.log 
mv Log.final.out $TAG.star_final.log
samtools index $TAG.bam 
