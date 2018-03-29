#!/bin/bash 

## PIPELINE VERSION

WDIR=$1
REFDIR=$2
SPECIES=$3
CPUS=$4
NJOB=$((CPUS/4))

KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do
  while [ $(jobs | wc -l) -ge $NJOB ] ; do sleep 5; done
  bowtie2_align.sh $i $WDIR $REFDIR $SPECIES 4 &
done
wait

cd ../bowtie2_rrna 
mkdir logs 
mv ../fastqs/*log logs 

echo "ALL BOWTIE2 rRNA ALIGMENTS ARE DONE!"
