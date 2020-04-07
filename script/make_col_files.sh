#!/bin/bash 

TAG=$1

## files necessary for expression table annotation 

echo "Generating 3-column annotation of genes (gene ID, gene name, gene type).."
grep -P "\tgene\t" $TAG.gtf | perl -ne '@t=split/\t/; m/gene_id "(.*?)";/; $id=$1; $nm = (m/gene_name "(.*?)";/) ? $1 : "NONE"; $tp = (m/gene_type "(.*?)";/) ? $1 : "NONE"; print "$id\t$nm\t$tp\n"' > $TAG.3col
echo "Done - results saved as $TAG.3col!"
echo

echo "Generating 4-column annotation of transcrips (transcript ID, parent gene ID, gene name, gene type).."
grep -P "\ttranscript\t" $TAG.gtf | perl -ne '@t=split/\t/; m/transcript_id "(.*?)";/; $tid=$1; $gid = (m/gene_id "(.*?)";/) ? $1 : "NONE"; $nm = (m/gene_name "(.*?)";/) ? $1 : "NONE"; $tp = (m/gene_type "(.*?)";/) ? $1 : "NONE"; print "$tid\t$gid\t$nm\t$tp\n"' > $TAG.4col
echo "Done - results saved as $TAG.4col!"
echo

echo
echo "ALL DONE!" 
