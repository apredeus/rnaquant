#!/bin/bash 

## PIPELINE VERSION

cd fastqs

REFDIR=$1
SPECIES=$2
CPUS=$3

KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do
  echo "STAR: running alignment for tag $i.." 
  ../star_align.sh $i $REFDIR $SPECIES $CPUS > $i.star_stdout.log 
done

mv *.star_stdout.log ../STAR_logs
mv *STAR/*log ../STAR_logs 
mv *STAR/*tr.bam ../tr_bams 
mv *STAR/*bam ../bams

rm -rf *STAR 

echo "ALL STAR ALIGMENT IS DONE!"
echo
echo
