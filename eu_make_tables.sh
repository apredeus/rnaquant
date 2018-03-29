#!/bin/bash

WDIR=$1
REFDIR=$2
SPECIES=$3
ANN3=$REFDIR/Assemblies/$SPECIES/${SPECIES}.3col
ANN4=$REFDIR/Assemblies/$SPECIES/${SPECIES}.4col


## make expression table of counts/TPM for rsem

cd $WDIR/RSEM

echo -e "Gene_id\tSymbol\tGene_type" > $$.names
cat $ANN3 | sort -k1,1 >> $$.names

RSEM=`ls *.rsem.genes.tsv`

for i in $RSEM
do
  TAG=${i%%.rsem.genes.tsv}
  echo $TAG > $TAG.counts.tmp
  echo $TAG > $TAG.TPM.tmp
  awk '{if (NR>1) print}' $i | sort -k1,1 | cut -f 5 >> $TAG.counts.tmp
  awk '{if (NR>1) print}' $i | sort -k1,1 | cut -f 6 >> $TAG.TPM.tmp 
done

paste $$.names *.counts.tmp      > ../exp_tables/rsem.genes.counts.tsv  
paste $$.names *.TPM.tmp         > ../exp_tables/rsem.genes.TPM.tsv  
rm *counts.tmp *TPM.tmp $$.names

## make expression table of counts/TPM for kallisto
cd ../kallisto

echo -e "Transcript_id\tGene_id\tSymbol\tGene_type" > $$.names
cat $ANN4 | sort -k1,1 >> $$.names

KLST=`ls *.kallisto.isoforms.tsv`

for i in $KLST
do
  TAG=${i%%.kallisto.isoforms.tsv}
  echo $TAG > $TAG.counts.tmp
  echo $TAG > $TAG.TPM.tmp
  awk '{if (NR>1) print}' $i | sort -k1,1 | cut -f 4 >> $TAG.counts.tmp
  awk '{if (NR>1) print}' $i | sort -k1,1 | cut -f 5 >> $TAG.TPM.tmp 
done

paste $$.names *.counts.tmp      > ../exp_tables/kallisto.isoforms.counts.tsv  
paste $$.names *.TPM.tmp         > ../exp_tables/kallisto.isoforms.TPM.tsv  
rm *counts.tmp *TPM.tmp $$.names

echo "ALL EXPRESSION TABLE PROCESSING IS DONE!" 
