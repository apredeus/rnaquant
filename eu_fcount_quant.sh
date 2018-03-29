#!/bin/bash 

## PIPELINE VERSION

TAG=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
STRAND=$5
FLAG=""
PAIRED="" 

cd $WDIR/fastqs 

if [[ -e $TAG.R1.fastq.gz && -e $TAG.R2.fastq.gz ]]
then
  PAIRED="-p" 
fi 

EXTREF=$REFDIR/Assemblies/$SPECIES.extended.gff
cd $WDIR/featureCounts

if [[ $TAG == "" || $SPECIES == "" || $REFDIR == "" ]]
then 
  echo "ERROR: Please provide 1) output name (tag) assuming <tag>.fastq.gz or <tag>.R1.fastq.gz/<tag>.R2.fastq.gz input; 2) species/assembly alias, e.g. genprime_v23; 3) strandedness as NONE/FR/RF"
  exit 1
fi
 
if [[ $STRAND == "NONE" ]]
then
  FLAG="0"
  echo "featureCounts: processing sample $TAG, strandedness $STRAND (-s $FLAG), PE options: $PAIRED"
elif [[ $STRAND == "FR" ]]
then
  FLAG="1"
  echo "featureCounts: processing sample $TAG, strandedness $STRAND (-s $FLAG), PE options: $PAIRED"
elif [[ $STRAND == "RF" ]]
then
  FLAG="2"
  echo "featureCounts: processing sample $TAG, strandedness $STRAND (-s $FLAG), PE options: $PAIRED"
else
  echo "ERROR: you must set strand variable to either NONE, FR, or RF"
  exit
fi

featureCounts $PAIRED -t gene -g ID -s $FLAG -a $EXTREF -o $TAG.ext_fc.tsv $WDIR/bams/$TAG.bam &> $TAG.ext_fc.log
cp ../strand/$TAG.fc.s$FLAG.tsv $TAG.fc.tsv 
cp ../strand/logs/$TAG.fc.s$FLAG.log $TAG.fc.log
