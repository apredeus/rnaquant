#!/bin/bash 

REFDIR=$1
SPECIES=$2 ## e.g. genprime_vM12
CPUS=$3
WDIR=`pwd`

if [[ $# != "3" ]]
then
  echo "=================================================================================="
  echo "=================================================================================="
  echo "===                                                                            ==="
  echo "===              What is the airspeed velocity of an unladen swallow?          ==="
  echo "===                                                                            ==="
  echo "===                  Usage: rnaquant.sh <ref_dir> <tag> <CPUs>                 ===" 
  echo "===   For more usage information, visit https://github.com/apredeus/rnaquant   ==="
  echo "===                                                                            ==="
  echo "=================================================================================="
  echo "=================================================================================="
  exit 1
fi

cd $WDIR

echo "=================================================================================="
echo "=================================================================================="
echo "===                                                                            ==="
echo "===                             Welcome to Rnaquant!                           ==="
echo "===                       Quantify the shit out of shit (R)                    ==="
echo "===  For more information, please visit https://github.com/apredeus/rnaquant   ==="
echo "===                          Publication in preparation.                       ==="
echo "===                                                                            ==="
echo "=================================================================================="
echo "=================================================================================="
echo
echo

if [[ -d fastqs && "$(ls -A fastqs)" ]]; then
  echo "Found non-empty directory named fastqs! Continuing."
else
  echo "ERROR: directory fastqs does not exist and is empty!"
  exit 1
fi

if [[ ! -d bams || ! -d picard_stats || ! -d fc_stats || ! -d tdfs_and_bws || \
! -d RSEM || ! -d featureCounts || ! -d FastQC || ! -d STAR_logs || \
! -d kallisto || ! -d exp_tables || ! -d bowtie2_rrna || ! -d tr_bams ]]
then
  echo "One of the required directories is missing, I will try to create them."
  mkdir bams picard_stats fc_stats tdfs_and_bws RSEM featureCounts FastQC kallisto exp_tables bowtie2_rrna STAR_logs tr_bams
else
  echo "All the necessary directories found, continuing." 
fi

if [[ $SPECIES == "" || $REFDIR == "" ]]
then
  echo "ERROR: You have to specify REFDIR and SPECIES!"
  exit 1
fi

if [[ $CPUS == "" ]]
	then 
  echo "Parallel jobs have been set to default - running on 16 cores."
  CPUS=16
else 
  echo "Parallel jobs will be ran on $CPUS cores."
fi

echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 1: Running FastQC.."
cd $WDIR/fastqs 
eu_prun_fastqc.sh $WDIR $CPUS
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 2: Running rRNA content evaluation via Bowtie2 alignment.."
cd $WDIR/fastqs 
eu_prun_bowtie2.sh $WDIR $REFDIR $SPECIES $CPUS
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 3: Running STAR genome and transcriptome alignment.."
cd $WDIR/fastqs
eu_prun_star.sh $WDIR $REFDIR $SPECIES $CPUS
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 4: Making TDF and strand-specific bigWig files.."
cd $WDIR/bams
eu_prun_coverage.sh $WDIR $REFDIR $SPECIES $CPUS
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 5: Running featureCounts on all possible strand settings.."
cd $WDIR/bams
eu_prun_strand.sh $WDIR $REFDIR $SPECIES $CPUS
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 6: Calculating strandedness from featureCounts.."
cd $WDIR/fastqs
eu_prun_stats.sh $WDIR
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 7: Calculating strandedness and other stats using Picard tools.."
cd $WDIR/picard_stats
eu_prun_picard.sh $WDIR $REFDIR $SPECIES $CPUS
echo 
echo "=================================================================================="
echo

cd $WDIR/picard_stats
STRANDP=`grep PCT_CORRECT_STRAND_READS -A 1 *.picard.metrics | awk -F "\t" '{print $23}' | grep -v -P "^$|PCT_CORRECT_STRAND_READS" | awk '{sum+=$1} END {printf "%.2f\n",sum*100/NR}'`
echo "Strandedness estimates: $STRANDP (Picard tools)."

cd $WDIR/featureCounts 
cat *strand | awk 'BEGIN {min=100;max=0} {sum+=$16; if($16>max) \
{max=$16}; if($16<min) {min=$16};} END {print "featureCounts: average percent of \
reads matching the coding strand: "sum/NR", lowest: "min", highest: "max}'

STRAND=`cat *strand | awk '{sum+=$16} END {x=sum/NR; if (x<10) \
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

echo "["`date +%H:%M:%S`"] Step 8: Running kallisto abundance estimation.."
cd $WDIR/fastqs
eu_prun_kallisto.sh $WDIR $REFDIR $SPECIES $CPUS $STRAND
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 9: Running RSEM abundance estimation.."
cd $WDIR/tr_bams
eu_prun_rsem.sh $WDIR $REFDIR $SPECIES $CPUS $STRAND
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] Step 10: Making final expression tables.."
cd $WDIR/featureCounts
eu_make_tables.sh $WDIR $REFDIR $SPECIES 
echo 
echo "=================================================================================="
echo

echo "["`date +%H:%M:%S`"] ALL PROCESSING IS NOW COMPLETE!"
