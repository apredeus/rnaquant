#!/bin/bash 

## PIPELINE VERSION

cd fastqs

REFDIR=$1
SPECIES=$2
CPUS=$3 ## how many cores for individual jobs

KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do
  echo "bowtie2: running alignment for tag $i.." 
  ../bowtie2_align.sh $i $REFDIR $SPECIES $CPUS
done

cd ../rRNA
mkdir logs 
mv ../fastqs/*bowtie2_rrna.log logs

echo "ALL BOWTIE2 rRNA ALIGMENT IS DONE!"
echo
echo

