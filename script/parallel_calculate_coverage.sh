#!/bin/bash 

## PIPELINE VERSION

SDIR=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5

cd $WDIR/bams 
for i in *bam
do
  TAG=${i%%.bam}
  while [ $(jobs | wc -l) -ge $CPUS ] ; do sleep 5; done
  $SDIR/script/calculate_coverage.sh $TAG $WDIR $REFDIR $SPECIES & 
done
wait

cd ../tdfs_and_bws
mkdir logs
mv ../bams/*tdf .
mv ../bams/*bw .
mv ../bams/*.log logs 

echo "ALL COVERAGE CALCULATIONS ARE DONE!"
