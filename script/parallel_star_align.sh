#!/bin/bash 

## PIPELINE VERSION

SDIR=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5
JCPUS=""
NJOBS=""

if (( $CPUS >= 16 )) 
then
  JCPUS=4
elif (( $CPUS > 4 )) 
then
  JCPUS=2 
else 
  JCPUS=1
fi
NJOBS=$((CPUS/JCPUS))

KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do
  while [ $(jobs | wc -l) -ge $NJOBS ] ; do sleep 5; done
  $SDIR/script/star_align.sh $i $WDIR $REFDIR $SPECIES $JCPUS & 
done
wait

mv *STAR/*log ../STAR_logs 
mv *STAR/*tr.bam ../tr_bams 
mv *STAR/*bam *STAR/*bam.bai ../bams

rm -rf *STAR 

echo "ALL STAR ALIGMENTS ARE DONE!"
