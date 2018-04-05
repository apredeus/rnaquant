#!/bin/bash 

## PIPELINE VERSION

WDIR=$1
cd $WDIR/fastqs

KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do
  eu_calculate_stats.sh $i $WDIR &  
done
wait

echo "ALL RNA-STAT CALCULATIONS ARE DONE!"
