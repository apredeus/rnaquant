#!/bin/bash 

## PIPELINE VERSION

REFDIR=$1
SPECIES=$2
STRAND=$3
CPUS=$4

ANN=$REFDIR/Assemblies/${SPECIES}.3col

cd tr_bams 

for i in *tr.bam 
do 
  TAG=${i%%.tr.bam}
  echo "RSEM: processing sample $TAG, file $i.."
  ../rsem_quant.sh $TAG $REFDIR $SPECIES $STRAND $CPUS
done

cd ../RSEM
mkdir logs 
mv ../tr_bams/*log logs 
mv ../tr_bams/*results . 

echo -e "Gene_id\tSymbol\tGene_type" > names
cat $ANN | grep -v -i symbol >> names

PP=`ls *genes.results`

for i in $PP
do
  echo "processing file $i" 
  TAG=${i%%.genes.results}
  echo $TAG > $TAG.tmp
  awk '{if (NR>1) print $5}' $i >> $TAG.tmp
done

paste names *.tmp  > Rsem_gene_counts.tsv  
rm *.tmp names

echo "ALL RSEM QUANTIFICATION IS DONE!"
echo
echo
