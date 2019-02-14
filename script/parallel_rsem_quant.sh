#!/bin/bash 

SDIR=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5
STRAND=$6
NJOB=$((CPUS/4))

REF=$REFDIR/$SPECIES/${SPECIES}_rsem
if [[ -e $REF.ti ]]
then
  echo "RSEM: using reference $REF"
  echo 
else 
  >&2 echo "ERROR: rsem reference $REF not found!" 
  exit 1
fi 

source activate rsem

for i in *.tr.bam
do 
  TAG=${i%%.tr.bam} 
  while [ $(jobs | wc -l) -ge $NJOB ] ; do sleep 5; done
  $SDIR/script/rsem_quant.sh $TAG $WDIR $REF $STRAND 8 & 
done
wait

rm -rf *rsem.stat
cd ../RSEM
mkdir logs 
mv ../tr_bams/*log logs 
mv ../tr_bams/*results .

echo "ALL RSEM QUANTIFICATION IS DONE!"
