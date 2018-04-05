#!/bin/bash 

## PIPELINE VERSION

WDIR=$1
REFDIR=$2
SPECIES=$3
CPUS=$4

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
  eu_picard_stat.sh $i $WDIR $REFDIR $BAMDIR $LOGDIR $SPECIES &> $i.rnastat.log & 
done 
wait

mkdir logs 
mv *log logs 
