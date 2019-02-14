#!/bin/bash 

WDIR=$1
REFDIR=$2
SPECIES=$3
CPUS=$4
STRAND=$5
NJOB=$((CPUS/4))

REF=$REFDIR/RSEM/${SPECIES}_rsem
if [[ -e $REF.ti ]]
then
  echo "RSEM: using reference $REF"
else 
  echo "ERROR: rsem reference $REF not found!" 
fi 

source activate rsem

for i in *.tr.bam
do 
  TAG=${i%%.tr.bam} 
  while [ $(jobs | wc -l) -ge $NJOB ] ; do sleep 5; done
  eu_rsem_quant.sh $TAG $WDIR $REF $STRAND 8 & 
done
wait

rm -rf *rsem.stat
cd ../RSEM
mkdir logs 
mv ../tr_bams/*log logs 
mv ../tr_bams/*results .

echo "ALL RSEM QUANTIFICATION IS DONE!"
