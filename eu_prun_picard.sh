#!/bin/bash 

## PIPELINE VERSION

WDIR=$1
REFDIR=$2
SPECIES=$3

DIR=`pwd`
BAMDIR=$DIR/bams
LOGDIR=$DIR/STAR_logs 

cd $WDIR/bams
KK=`for i in *bam
do
  echo ${i%%.bam}
done`

cd $WDIR/picard_stat

for i in $KK
do
  picard_stat.sh $i $WDIR $REFDIR $BAMDIR $LOGDIR $SPECIES &> $i.rnastat.log & 
done 
wait

mkdir logs 
mv *log logs 
