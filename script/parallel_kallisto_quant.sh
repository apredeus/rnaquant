#!/bin/bash 

SDIR=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CPUS=$5
STRAND=$6
NJOB=$((CPUS/4))

REF=$REFDIR/$SPECIES/${SPECIES}_kallisto

if [[ -e $REF ]]
then
  echo "kallisto: using reference $REF"
  echo 
else 
  >&2 echo "ERROR: kallisto reference $REF not found!" 
  exit 1
fi 


KK=`for i in *fastq.gz
do 
  TAG1=${i%%.fastq.gz}
  TAG2=${TAG1%%.R?}
  echo $TAG2
done | sort | uniq`

for i in $KK
do 
  while [ $(jobs | wc -l) -ge $NJOB ] ; do sleep 5; done
  $SDIR/script/kallisto_quant.sh $i $WDIR $REF $STRAND 4 & 
done
wait

cd ../kallisto
mkdir logs 
mv ../fastqs/*log logs 
mv ../fastqs/*tsv . 

echo "ALL KALLISTO QUANTIFICATIONS ARE DONE!"
