#!/bin/bash 

## can be used for both single and paired-end
## archived FASTQ is assumed

TAG=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5

READS=""
RRNA=$REFDIR/bowtie2/${SPECIES}.rRNA
FQDIR=$WDIR/fastqs 
cd $FQDIR

if [[ $TAG == "" || $SPECIES == "" || $CPUS == "" ]]
then 
  echo "ERROR: Please provide TAG, SPECIES handle, and # of CPUS! for individual bowtie2 runs!"
  exit 1
fi 

if [[ -e $TAG.fastq.gz ]]
then 
  echo "bowtie2: processing sample $TAG as single-ended."
  READS="-U $FQDIR/$TAG.fastq.gz"
elif [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  echo "bowtie2: processing sample $TAG as paired-ended."
  READS="-1 $FQDIR/$TAG.R1.fastq.gz -2 $FQDIR/$TAG.R2.fastq.gz"
else
  echo "ERROR: The reqiured fastq.gz files were not found!" 
  exit 1
fi

if [[ ! -f $REFDIR/bowtie2/$SPECIES.rRNA.1.bt2 ]]
then 
  echo "ERROR: bowtie2 index $REF does not exist!"
  exit 1
fi

bowtie2 --very-sensitive-local -t -p $CPUS -x $RRNA $READS > /dev/null 2> $TAG.bowtie2_rrna.log
