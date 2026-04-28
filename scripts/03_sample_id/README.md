## Script 
03a_BLASTN_subset

### Purpose
Script to produce a FASTA subset of FASTQ R1 (forward) short reads to be used in a BLASTN search to identify sample origin.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/03_sample_id
```

2. Execute script

```{bash}
sbatch 03a_BLASTN_subset
```



### Overview
#### 1. Software
- Seqtk v1.5


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_R1_subset_1000` | .fastq  | None-zipped **FASTQ** file containing a subset of 1000 reads from Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_R1_subset_1000` | .fasta  | None-zipped **FASTA** file containing a subset of 1000 reads from Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |


#### 4. Command Descriptions
1. Create **FASTQ** subset
- ``sample`` = Take subsample
- ``-s100`` = Set random seed to 100
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``1000`` = Subset size = 1000 reads


```{bash}
seqtk sample -s100 <MERGED_SHORTREADS_R1.fastq.gz> 1000 > <MERGED_SHORTREADS_R1_SUBSET.fastq>
```

2. Convert **FASTQ** subset to **FASTA**
- ``seq -a`` = Converts FASTQ to FASTA
- ``<MERGED_SHORTREADS_R1_SUBSET.fastqc>`` = Input file containing FASTQ subset from Step 1: *Create FASTQ subset*
- ``> <MERGED_SHORTREADS_R1_SUBSET.fasta>`` = Redirects stdout to output file containing subset in FASTA format


```{bash}
seqtk seq -a <MERGED_SHORTREADS_R1_SUBSET.fastqc> > <MERGED_SHORTREADS_R1_SUBSET.fasta>
```


## Script 
03b_retrieve_reference_genome

### Purpose
Download Haloferax *volcanii* reference genome and annotation files from NCBI then index reference genome.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/03_sample_id
```

2. Execute script

```{bash}
sbatch 03b_retrieve_reference_genome
```



### Overview
#### 1. Software
- Bwa v0.7.19
- Samtools v1.23


#### 2. Input Files

N/A


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.gz  | Gzipped reference genome for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna  | None-zipped reference genome for Haloferax *volcanii*.    |
| `GCF_000025685.1_ASM2568v1_genomic` | .gff.gz  | Gzipped annotation for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .gbff.gz  | Gzipped annotation for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.amb  | None-zipped index file for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.ann  | None-zipped index file for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.bwt  | None-zipped index file for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.fai  | None-zipped index file for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.pac  | None-zipped index file for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.sa  | None-zipped index file for Haloferax *volcanii*.     |


#### 4. Command Descriptions
1. Download files from NCBI

```{bash}
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/025/685/GCF_000025685.1_ASM2568v1/GCF_000025685.1_ASM2568v1_genomic.gff.gz 
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/025/685/GCF_000025685.1_ASM2568v1/GCF_000025685.1_ASM2568v1_genomic.gbff.gz 
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/025/685/GCF_000025685.1_ASM2568v1/GCF_000025685.1_ASM2568v1_genomic.fna.gz 
```

2. Unzip reference genome FASTA for compatibility with indexing software
- ``gunzip -k`` = Unzip FASTA whilst retaining original zipped file

```{bash}
gunzip -k GCF_000025685.1_ASM2568v1_genomic.fna.gz
```


3. Index reference genome
- ``bwa index`` = Perform indexing using Bwa
- ``samtools faidx`` = Perform indexing using Samtools


```{bash}
bwa index GCF_000025685.1_ASM2568v1_genomic.fna
samtools faidx GCF_000025685.1_ASM2568v1_genomic.fna
```

