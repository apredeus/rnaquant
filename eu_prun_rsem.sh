#!/bin/bash 

WDIR=$1
REFDIR=$2
SPECIES=$3
CPUS=$4
STRAND=$5

REF=$REFDIR/RSEM/${SPECIES}_rsem
if [[ -e $REF.ti ]]
then
  echo "RSEM: using reference $REF"
else 
  echo "ERROR: rsem reference $REF not found!" 
fi 

source activate rsem

KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do 
  while [ $(jobs | wc -l) -ge $CPUS ] ; do sleep 5; done
  rsem_quant.sh $i $WDIR $REF $STRAND & 
done
wait

rm -rf *rsem.stat
cd ../RSEM
mkdir logs 
mv ../tr_bams/*log logs 
mv ../tr_bams/*results .

echo "ALL RSEM QUANTIFICATION IS DONE!"
