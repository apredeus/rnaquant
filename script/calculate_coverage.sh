#!/bin/bash 

TAG=$1
WDIR=$2
REFDIR=$3
SPECIES=$4
CHROM=$REFDIR/$SPECIES/$SPECIES.chrom.sizes
cd $WDIR/bams 

echo "Making bigWig and TDF files for sample $TAG.." 

igvtools count -z 5 -w 10 -e 0 $TAG.bam $TAG.tdf $CHROM &> $TAG.tdf.log  
