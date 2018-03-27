#!/bin/bash 

REFDIR=$1
SPECIES=$2 ## e.g. genprime_vM12
CPUS=$3

if [[ -d fastqs && "$(ls -A fastqs)" ]]; then
  echo "Found non-empty directory named fastqs! Continuing.."
else
  echo "ERROR: directory fastqs does not exist and is empty!"
  exit 1
fi

if [[ ! -d bams || ! -d tr_bams || ! -d stats || ! -d tdfs || ! -d strand || \
! -d RSEM || ! -d kallisto || ! -d FastQC || ! -d STAR_logs || ! -d rRNA ]]
then
  echo "One of the required directories is missing, I will try to create them..."
  mkdir bams tr_bams stats strand tdfs RSEM kallisto FastQC STAR_logs rRNA
else 
  echo "All the necessary directories found, continuing..." 
fi 

cp /home/user1/rnaseq/*sh .

if [[ $SPECIES == "" || $REFDIR == "" ]]
then
  echo "ERROR: You have to specify REFDIR and SPECIES!"
  exit 1
fi

if [[ $CPUS == "" ]]
	then 
  echo "Parallel jobs have been set to default - running on 4 cores."
  CPUS=4
else 
  echo "Parallel jobs will be ran on $CPUS cores."
fi

echo "["`date +%H:%M:%S`"] Step 1: Running FastQC.."
./prun_fastqc.sh
echo "["`date +%H:%M:%S`"] Step 2: Running Bowtie2 for rRNA.."
./prun_bowtie2.sh $REFDIR $SPECIES $CPUS
echo "["`date +%H:%M:%S`"] Step 3: Running STAR.."
./prun_star.sh $REFDIR $SPECIES $CPUS
echo "["`date +%H:%M:%S`"] Step 4: Making TDF files.."
./pmake_tdf.sh $SPECIES
echo "["`date +%H:%M:%S`"] Step 5: Assessing strand specificity.."
./prun_strand.sh $REFDIR $SPECIES $CPUS
echo "["`date +%H:%M:%S`"] Step 6: Calculating strandedness and other statistics.."
./prun_stat.sh 

cd stats
cat *rnastat | awk 'BEGIN {min=100;max=0} {sum+=$16; if($16>max) \
{max=$16}; if($16<min) {min=$16};} END {print "Average percent of \
reads matching the coding strand: "sum/NR", lowest: "min", highest: "max}'

STRAND=`cat *rnastat | awk '{sum+=$16} END {x=sum/NR; if (x<10) \
{print "RF"} else if (x>90) {print "FR"} else if (x>45 && x<55) \
{print "NONE"} else {print "ERROR"}}'`

if [[ $STRAND == "ERROR" ]]
then
  echo "ERROR: something is very much off with the strand-specificity of your RNA-seq!"
  exit 1
else
  echo "The strandedness of your experiment was determined to be $STRAND"
fi
cd ..

echo "["`date +%H:%M:%S`"] Step 7: Running kallisto.."
./prun_kallisto.sh $REFDIR $SPECIES $STRAND $CPUS
echo "["`date +%H:%M:%S`"] Step 8: Running RSEM.."
./prun_rsem.sh $REFDIR $SPECIES $STRAND $CPUS

echo "["`date +%H:%M:%S`"] ALL PROCESSING IS NOW COMPLETE!"
