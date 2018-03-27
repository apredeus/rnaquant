#!/bin/bash

## local version w/modern Picard 

TAG=$1
REFDIR=$2
BAMDIR=$3
LOGDIR=$4
SPECIES=$5

DIR=`pwd`

#RRNA=$REFDIR/Assemblies/$SPECIES.rRNA_merged.intervals
GENOME=$REFDIR/Assemblies/$SPECIES.fa
REFFLAT=$REFDIR/Assemblies/$SPECIES.refFlat.txt
PICARD=~/picard/dist

## number of reads in FASTQ
R1=`grep "Number of input reads" $LOGDIR/$TAG.star_final.log  | awk '{print $6}'`
## number of unmapped reads  
P1=`grep "Uniquely mapped reads %"                  $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
P2=`grep "% of reads mapped to multiple loci"       $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
P3=`grep "% of reads mapped to too many loci"       $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
P4=`grep "% of reads unmapped: too many mismatches" $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
P5=`grep "% of reads unmapped: too short"           $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
P6=`grep "% of reads unmapped: other"               $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`

Pm=`echo $P1 | awk '{print $1+v1+v2}' v1=$P2 v2=$P3`
Pum=`echo $P4 | awk '{print $1+v1+v2}' v1=$P5 v2=$P6`
Pall=`echo $Pm | awk '{print $1+v1}' v1=$Pum`

echo "The sum of all reported percentages is estimated at $Pall"

echo "done calculating FASTQ and BAM statistics"
echo "---------------------------------------------------------------------------------------------------------"

#picard CollectRnaSeqMetrics INPUT=$BAMDIR/$TAG.bam OUTPUT=$TAG.picard.metrics REF_FLAT=$REFFLAT RIBOSOMAL_INTERVALS=$RRNA STRAND_SPECIFICITY=FIRST_READ_TRANSCRIPTION_STRAND REFERENCE_SEQUENCE=$GENOME
picard CollectRnaSeqMetrics INPUT=$BAMDIR/$TAG.bam OUTPUT=$TAG.picard.metrics REF_FLAT=$REFFLAT STRAND_SPECIFICITY=FIRST_READ_TRANSCRIPTION_STRAND REFERENCE_SEQUENCE=$GENOME

#percent reads aligned to ribosomal RNA
P7=""
#percent reads aligned to coding regions
P8=""
#percent reads aligned to UTR regions 
P9=""
#percent reads aligned to intronic regions 
P10=""
#percent reads aligned to intergenic regions 
P11=""

KK=`grep -A 2 "METRICS CLASS" $TAG.picard.metrics | awk '{if (NR==2) print}'`
LL=`grep -A 2 "METRICS CLASS" $TAG.picard.metrics | awk '{if (NR==3) print}'`
a=( $KK )
b=( $LL )
i=0
while [[ ${a[$i]} != "" ]]
do
  if [[ ${a[$i]} == "PCT_RIBOSOMAL_BASES" ]];  then P7=`echo ${b[$i]}  | awk '{printf "%.2f",$1*100}'`; fi
  if [[ ${a[$i]} == "PCT_CODING_BASES" ]];     then P8=`echo ${b[$i]}  | awk '{printf "%.2f",$1*100}'`; fi
  if [[ ${a[$i]} == "PCT_UTR_BASES" ]];        then P9=`echo ${b[$i]}  | awk '{printf "%.2f",$1*100}'`; fi
  if [[ ${a[$i]} == "PCT_INTRONIC_BASES" ]];   then P10=`echo ${b[$i]} | awk '{printf "%.2f",$1*100}'`; fi
  if [[ ${a[$i]} == "PCT_INTERGENIC_BASES" ]]; then P11=`echo ${b[$i]} | awk '{printf "%.2f",$1*100}'`; fi
  i=$((i+1))
done

## rm $TAG.picard.metrics

echo "done calculating PICARD metrics" 
echo "---------------------------------------------------------------------------------------------------------"

#found junctions 
P12=`grep "Mismatch rate per base, % "               $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
J1=`grep "Number of splices: Total"                  $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}'`
J2=`grep "Number of splices: Non-canonical"          $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}'`
P13=`echo $J1 | awk '{printf "%.2f",v1*100/$1}' v1=$J2`
Dr=`grep "Deletion rate per base"                    $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
Dl=`grep "Deletion average length"                   $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
Ir=`grep "Insertion rate per base"                   $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`
Il=`grep "Insertion average length"                  $LOGDIR/$TAG.star_final.log  | awk -F "\t" '{print $2}' | sed "s/%//g"`

echo "done calculating insertion, deletion, and junction metrics" 

#echo -e "Sample\tN_reads\tPct_mapped\tPct_mapped_1loc\tPct_unmapped\tPct_rRNA\tPct_coding\tPct_UTR\tPct_intronic\tPct_intergenic\tJunctions\tInsertion_rate\tDeletion_rate\tPct_NC_junctions\tDel_av_length\tIns_av_length"
echo -e "$TAG\t$R1\t$Pm\t$P1\t$Pum\t$P7\t$P8\t$P9\t$P10\t$P11\t$J1\t$Ir\t$Dr\t$P13\t$Dl\t$Il" > $TAG.rnastat


