#!/bin/bash 

## PIPELINE VERSION

REFDIR=$1
SPECIES=$2
CPUS=$3

cd bams

for i in *.bam 
do 
  TAG=${i%%.bam}
  echo "featureCounts: processing sample $TAG, file $i.."
  while [ $(jobs | wc -l) -ge $CPUS ] ; do sleep 5; done
  ../strand_quant.sh $TAG $REFDIR $SPECIES & 
done

wait

rm *summary
cd ../strand
mkdir logs
mv ../bams/*.fc.*log logs 
mv ../bams/*.fc.*tsv . 

echo "ALL STRANDEDNESS EVALUATION IS DONE!"
echo
echo

