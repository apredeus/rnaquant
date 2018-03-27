# rnaquant
RNA-seq quantification pipeline for eukaryotic species.

## Author
[Alexander Predeus](https://www.researchgate.net/profile/Alexander_Predeus), [Bioinformatics Institute](https://bioinf.me/en/research), Saint Petersburg

(c) 2016-2018, GPL v3 license

## Motivation
RNA-seq processing includes multiple steps, with best practices often varying between different species and laboratories. This pipeline deals with quality control, alignment, visualization, and quantification of bacterial RNA-seq experiments. 

RNA-seq processing also differs substantially between model species (human, mouse, rat), and non-model species due to the differences in file formats and annotation. We have tried to make a collection of methods that would be useable in each case without much additional pre-processing. 

When successfully applied, this should generate:
* checked and properly formatted GTF/GFF reference and alignment indexes; 
* genomic bam files for read-resolution visualization and analysis;
* TDF files for visualization in IGV;
* scaled bigWig files and trackList.json for visualization in JBrowse (see [doi:10.1128/mBio.01442-14](http://mbio.asm.org/content/5/4/e01442-14.full) for description of scaling); 
* three expression tables - from [featureCounts](http://subread.sourceforge.net/), [rsem](https://deweylab.github.io/RSEM/), and [kallisto](https://pachterlab.github.io/kallisto/), streamlined for visualisation and analysis in [Phantasus](http://genome.ifmo.ru/phantasus/); 
* a single [MultiQC](http://multiqc.info/) quality control report.

## Installation and requirements 
Clone the pipeline scripts into your home directory and add them to $PATH variable in bash: 

```bash
cd ~
git clone https://github.com/apredeus/rnaquant
echo "export ~/rnaquant:$PATH" >> .bashrc
```
To install the requirements, use [Bioconda](https://bioconda.github.io/). These are the programs that need to be installed: 

```bash
conda install fastqc
conda install bowtie
conda install tophat 
conda install star 
conda install samtools
conda install bedtools
conda install igvtools
conda install rsem
conda install kallisto
conda install subread
```

You also need to have Perl installed. Sorry. 

## Platform compatibility
This pipeline would work for eukaryotic RNA-seq experiments, both poly-A selected and rRNA depleted. It would work for any sort of strand-specificity, and it would automatically determine the type and process accordingly. Supported platforms include:
* Illumina;
* SOLiD (colorspace reads); 
* 454;
* Ion Torrent. 

This pipeline would **not** work for long-read RNA-seq experiments (cDNA from PacBio and Oxford Nanopore, and direct RNA-seq from the latter). These require a different aligners and probably different quantification approaches. 

This pipeline is also **not** recommended for bacterial RNA-seq processing. If that's what you're interested in, please see [bacpipe](https://github.com/apredeus/bacpipe/) and [multi-bacpipe](https://github.com/apredeus/multi-bacpipe). 

## One-command RNA-seq processing
After all the references are successfully created, simply run 

`rnaquant.sh <reference_dir> <tag> <CPUs>`

Rnaquant script needs to be ran in a writeable directory with a non-empty fastqs folder in it. 

Rnaquant:
* handles archived (.gz) and non-archived fastq files; 
* handles single-end and paired-end reads; 
* automatically detects strand-specificity of the experiment; 
* performs quantification according to the calculated parameters. 

The following steps are performed during the pipeline execution for Illumina/454/Ion Torrent: 
* FastQC is ran on all of the fastq files; 
* bowtie2 is used to align the fastq files to the rRNA and tRNA reference to accurately estimate rRNA/tRNA content; 
* fastq files that **failed** to align to rRNA/tRNA are placed in cleaned_fastq directory; 
* STAR is used to align the cleaned fastq files to the genome **and** to the transcriptome. Two *bam* files are generated - genomic file is sorted by coordinate, while transcriptomic file is kept purposfully random; 
* *tdf* files are prepared using genomic *bam* for visualization in IGV; 
* *bigWig (bw)* files are prepared for vizualization in majority of other genomic browsers; files are scaled to 
* featureCounts is ran on genomic *bam* to evaluate the strandedness of the experiment; 
* strandedness and basic alignment statistics are calculated; 
* featureCounts output is chosen based correct settings of strandedness; 
* rsem is ran on transcriptomic *bam* for EM-based quantification; 
* kallisto is ran on cleaned fastq to validate the RSEM results; 
* appropriately formatted logs are generated; 
* multiqc is ran to summarize everything as a nicely formatted report. 

In case of SOLiD (colorspace) reads, the processing follows a somwhat different protocol: 
* FastQC is ran on all of the fastq files; 
* bowtie is used to align the fastq files to the rRNA and tRNA reference to accurately estimate rRNA/tRNA content; 
* fastq files that **failed** to align to rRNA/tRNA are placed in cleaned_fastq directory; 
* tophat is used to align the cleaned *fastq* files to the genome; 
* *sam* alignments are converted to *bam*, sorted, and indexed; 
* *tdf* files are prepared for visualization in IGV; 
* *bigWig (bw)* files are prepared for vizualization in majority of other genomic browsers; 
* featureCounts is ran on genomic *bam* to evaluate the strandedness of the experiment; 
* strandedness and basic alignment statistics are calculated; 
* featureCounts output is chosen based correct settings of strandedness; 
* rsem with bowtie is ran on cleaned *fastq* for EM-based quantification; 
* appropriately formatted logs are generated; 
* multiqc is ran to summarize everything as a nicely formatted report. 
    
In the end you are expected to obtain a number of new directories: FastQC, bams, tdfs_and_bws, RSEM, kallisto, stats, strand, featureCounts, exp_tables. Each directory would contain the files generated by its namesake, as well as all appropriate logs. The executed commands with all of the versions and exact options are recorded in the master log. 
