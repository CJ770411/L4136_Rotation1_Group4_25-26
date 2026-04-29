## Script 
00_pipeline

### Purpose
Script to execute the analysis pipeline for Sample 1 and Sample 4:

1. Merge reads
2. Reads quality control (QC)
3. Identify sample origin
4. Genome assembly
5. Polish genome assemblies
6. Genome assembly QC
7. Genome assembly annotation
8. Genome assembly alignment to reference genome
9. Variant analysis

### Usage
- ARG1 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R1
- ARG2 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R2
- ARG3 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, pass data
- ARG4 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, fail data
- ARG5 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R1
- ARG6 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R2
- ARG7 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, pass data
- ARG8 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, fail data

-Use wildcards to pass multiple of the same file type in each argument. Ensure absolute paths are in quotes if it contains a wildcard e.g.:
``"/abs/path/to/file/H3932_S4_L00*_R1_001.fastq.gz"``

-This script is suitable and required for single files in any argument as it is still necessary for these files to be re-named according to the conventions defined within this script to allow downstream processing.

-Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/00_pipeline
```

2. Execute script

```{bash}
sbatch 00_pipeline.sh <ARG1> <ARG2> <ARG3> <ARG4> <ARG5> <ARG6> <ARG7> <ARG8>
```


### Overview
#### 1. Software
- Fastqc 0.12.1
- Nanoplot 1.46.2
- Unicycler 0.5.1
- Racon 1.5.0
- Pilon 1.24
- Picard 2.20.4
- Seqtk 1.5
- Quast 5.3.0
- Sambamba 1.0.1
- Samtools 1.23
- Bwa 0.7.19
- Minimap2 2.30
- Vcftools 0.1.17
- Prokka 1.15.6
- Genovi 0.4.3
- (module) bcftools-uoneasy/1.19-GCC-13.2.0






#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Illumina short read R1 (forward reads) for **sample 1**      |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Illumina short read R2 (reverse reads) for **sample 1**      |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore long reads (pass data only) for **sample 1**    |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore long reads (fail data only) for **sample 1**    |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Illumina short read R1 (forward reads) for **sample 4**      |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Illumina short read R2 (reverse reads) for **sample 4**      |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore long reads (pass data only) for **sample 4**    |
| *user-defined* | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore long reads (fail data only) for **sample 4**    |


#### 3. Output Files
Output files detailed in README for each script.



#### 4. Command Descriptions
**1. Call scripts**
- ``<JOB_ID_b>=$(sbatch --parsable --dependency=afterok:<JOB_ID_a> <SCRIPT.sh>)`` = Executes a script `<SCRIPT.sh>` using `sbatch` only upon completion of a previous job `<JOB_ID_a>` and records the new job ID in a variable `<JOB_ID_b>`

```{bash}
<JOB_ID_b>=$(sbatch --parsable --dependency=afterok:<JOB_ID_a> <SCRIPT.sh>)
```




**2. Record completion of scripts**
- ``sbatch --dependency=afterok:<JOB_ID>`` = Submits script as `sbatch` only upon completion of a previous job `<JOB>`.
- ``--wrap`` = Submit a one-line shell command.
- ``echo \"\$(date): Completed script: <SCRIPT_NAME>\"`` = Writes a time-stamped completion message recording the completion of a script as `<SCRIPT_NAME>`.
- ``>> <LOG_FILE>`` = Appends the completion message to a log file without overwriting previous entries.

```{bash}
sbatch --dependency=afterok:<JOB_ID> --wrap \
"echo \"\$(date): Completed script: <SCRIPT_NAME>\" >> <LOG_FILE.txt>"
```



