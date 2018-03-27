#!/bin/bash

## PIPELINE VERSION

cd bams 
SPECIES=$1

KK=`for i in *bam
do
  echo ${i%%.bam}
done`

for i in $KK
do 
  echo "igvtools: Making TDF files for sample $i.." 
  igvtools count -z 5 -w 50 -e 0 $i.bam $i.tdf $SPECIES >& $i.tdf.log & 
done 

wait 

cd ../tdfs

mkdir logs
mv ../bams/*log logs 
mv ../bams/*tdf .

echo "ALL TDF PREPARAION IS DONE!"
echo
echo


