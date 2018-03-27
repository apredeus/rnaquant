#!/bin/bash 

## PIPELINE VERSION

REFDIR=$1
SPECIES=$2

DIR=`pwd`
BAMDIR=$DIR/bams
LOGDIR=$DIR/STAR_logs 

cd bams
KK=`for i in *bam
do
  echo ${i%%.bam}
done`

cd ../stats

echo $KK | tr ' ' '\n' | split -l 8 -d -

for j in x0?  ## you won't have more than 80 files to process, will ya? 
do 
  for k in `cat $j`
  do
    echo "Collecting statistics for sample $i.."
    ../star_stat.sh $k $REFDIR $BAMDIR $LOGDIR $SPECIES &> $k.rnastat.log & 
  done 
  wait
done 

mkdir logs 
mv *log logs 
rm x0? 


