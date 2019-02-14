#!/bin/bash 

## PIPELINE VERSION

SDIR=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5

for i in *.bam 
do 
  TAG=${i%%.bam}
  while [ $(jobs | wc -l) -ge $CPUS ] ; do sleep 5; done
  $SDIR/script/strand_quant.sh $TAG $WDIR $REFDIR $SPECIES & 
done

wait

rm *summary
cd ../featureCounts
mkdir logs
mv ../bams/*.fc.*log logs 
mv ../bams/*.fc.*tsv . 

echo "ALL STRANDEDNESS EVALUATION IS DONE!"
