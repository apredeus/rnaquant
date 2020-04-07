#!/bin/bash 

## this one is to generate Picard tools "refflat" type annotation from Gencode/Ensembl GTFs. 
## requires Jim Kent's gtfToGenePred

GTF=$1
TYPE=$2
TAG=${GTF%%.gtf} 

if [[ $# != 2 ]] 
then 
  >&2 echo "USAGE: ./gtf_to_refflat.sh <gtf_file> ens (for Ensembl GTF), or " 
  >&2 echo "       ./gtf_to_refflat.sh <gtf_file> gen (for Gencode, etc)" 
  exit 1
fi

if [[ $TYPE == "gen" ]]
then
  gtfToGenePred -ignoreGroupsWithoutExons $GTF $TAG.$$.tmp1
  sort -k1,1 $TAG.$$.tmp1 > $TAG.$$.tmp2
  grep -P "\ttranscript\t" $GTF | perl -ne 'print "$1\t$2\n" if m/transcript_id \"(.*)\"\; gene_type.*gene_name \"(.*)\"\; transcript_type/g' | sort -k1,1 | uniq | awk '{print $2}' > $TAG.$$.tmp3
  paste $TAG.$$.tmp3 $TAG.$$.tmp2 | sort -k3,3 -k5,5n > $TAG.refFlat.txt
  rm *.$$.tmp?
elif [[ $TYPE == "ens" ]]
then 
  gtfToGenePred -ignoreGroupsWithoutExons $GTF $TAG.$$.tmp1
  sort -k1,1 $TAG.$$.tmp1 > $TAG.$$.tmp2

  grep -P "\ttranscript\t" $GTF | perl -ne 'print "$1\t$2\n" if m/transcript_id \"(.*?)\"\;.*gene_name \"(.*?)\"\;/g' | sort -k1,1 | awk '{print $2}' > $TAG.$$.tmp3
  KK1=`wc -l $TAG.$$.tmp2 | awk '{print $1}'`
  KK2=`wc -l $TAG.$$.tmp3 | awk '{print $1}'`
  echo "Listed $KK1 entries in GenePred file, and $KK2 transcripts extracted from the $GTF file".
  paste $TAG.$$.tmp3 $TAG.$$.tmp2 | sort -k3,3 -k5,5n > $TAG.refFlat.txt
  rm *.$$.tmp?
else 
  >&2 echo "ERROR: please specify GFF type as \"ens\" or \"gen\""
  exit 1
fi
