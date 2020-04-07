#!/bin/bash 

FA=$1
GTF=$2
RLEN=$3

if [[ $FA == "" || $GTF == "" || $RLEN == "" ]] 
then
  >&2 echo "USAGE: star_prepare_reference.sh <genome_fa> <genome_gtf> <read_length>" 
  exit 1
fi 

TAG=${FA%%.fa} 

mkdir $TAG.STAR

STAR --runThreadN 64 --runMode genomeGenerate --genomeDir $TAG.STAR --genomeFastaFiles $FA --sjdbGTFfile $GTF --sjdbOverhang $((RLEN-1)) 

