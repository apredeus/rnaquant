#!/bin/bash

## make intervals for Picard CollectRnaSeqMetrics

TAG=$1
HEADER=$2  ## a header from one of the RNA-seq alignments 

cat $HEADER > $TAG.rRNA.intervals
grep -P "\tgene\t" $TAG.gtf | grep "gene_type \"rRNA\"" | perl -ne '@t=split/\t/; m/gene_name "(.*?)";/; print "$t[0]\t$t[3]\t$t[4]\t$t[6]\t$1\n"' >> $TAG.rRNA.intervals
