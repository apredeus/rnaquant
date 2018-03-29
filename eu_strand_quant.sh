#!/bin/bash 

## PIPELINE VERSION

TAG=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
REF=$REFDIR/Assemblies/$SPECIES/$SPECIES.gtf
PAIRED=""

cd $WDIR/fastqs 

if [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  ## in case of PE library, you want to be counting fragments 
  PAIRED="-p" 
  echo "featureCounts: processing sample $TAG, PE options: $PAIRED" 
fi 

cd $WDIR/bams 

if [[ $TAG == "" || $SPECIES == "" || $REFDIR == "" ]]
then 
  echo "ERROR: Please provide 1) output name (tag); 2) reference directory (see manual); 3) species tag (see manual)"
  exit 1
fi

## note that you ABSOLUTELY have to have $PAIRED set correctly 
## otherwise a strand-specific PE library would look EXACTLY like a non-specific SE! 
 
featureCounts $PAIRED -t exon -g gene_id -s 0 -a $REF -o $TAG.fc.s0.tsv $TAG.bam &> $TAG.fc.s0.log & 
featureCounts $PAIRED -t exon -g gene_id -s 1 -a $REF -o $TAG.fc.s1.tsv $TAG.bam &> $TAG.fc.s1.log & 
featureCounts $PAIRED -t exon -g gene_id -s 2 -a $REF -o $TAG.fc.s2.tsv $TAG.bam &> $TAG.fc.s2.log & 

wait 
