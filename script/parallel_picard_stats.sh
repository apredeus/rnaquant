#!/bin/bash 

## PIPELINE VERSION

SDIR=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5

BAMDIR=$WDIR/bams
LOGDIR=$WDIR/STAR_logs 

cd $WDIR/bams
KK=`for i in *bam
do
  echo ${i%%.bam}
done`

cd $WDIR/picard_stats

for i in $KK
do
  while [ $(jobs | wc -l) -ge $CPUS ] ; do sleep 5; done
  $SDIR/script/picard_stats.sh $i $WDIR $REFDIR $BAMDIR $LOGDIR $SPECIES &> $i.rnastat.log & 
done 
wait

mkdir logs 
mv *log logs 
