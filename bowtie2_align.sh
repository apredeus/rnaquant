#!/bin/bash 

## can be used for both single and paired-end
## archived FASTQ is assumed

TAG=$1
REFDIR=$2
SPECIES=$3
CPUS=$4

READS=""
RRNA=$REFDIR/bowtie2/${SPECIES}.rRNA
WDIR=`pwd`

if [[ $TAG == "" || $REFDIR == "" || $SPECIES == "" || $CPUS == "" ]]
then 
  echo "ERROR: Please provide TAG, REFDIR reference directory, SPECIES handle, and # of CPUS for individual bowtie2 runs!"
  exit 1
fi 

if [[ -e $TAG.fastq.gz ]]
then 
  echo "Processing alignment as single-end, using bowtie2 index $RRNA."
  READS="-U $WDIR/$TAG.fastq.gz"
elif [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  echo "Processing alignment as paired-end, using bowtie2 index $RRNA."
  READS="-1 $WDIR/$TAG.R1.fastq.gz -2 $WDIR/$TAG.R2.fastq.gz"
else
  echo "ERROR: The reqiured fastq.gz files were not found!" 
  exit 1
fi

bowtie2 --very-fast-local -t -p $CPUS -x $RRNA $READS > /dev/null 2> $TAG.bowtie2_rrna.log 
