## Script 
02a_shortread_qc

### Purpose
Script to perform QC on short read Illumina data.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/02_reads_qc
```

2. Execute script

```{bash}
sbatch 02a_shortread_qc.sh
```



### Overview
#### 1. Software
- FastQC v0.12.1


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.      |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_shortread_R1` | .html  | Report containing various quality control statistics for short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_shortread_R2` | .html  | Report containing various quality control statistics for short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.      |


#### 4. Command Descriptions
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``-o <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/reads_qc/shortread`*
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.

```{bash}
fastqc \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
-o <OUTDIR> \
-t $SLURM_CPUS_PER_TASK
```




## Script 
02b_nanoplot_longread_qc

### Purpose
Script to perform QC on long read Nanopore data

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/02_reads_qc
```

2. Execute script

```{bash}
sbatch 02a_shortread_qc.sh
```



### Overview
#### 1. Software
- Nanoplot 1.46.2


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_longread` | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore **merged** long reads (pass and fail data) where `<SAMPLE>` = sample 1 or sample4.    |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `NanoPlot-report` | .html  | Report containing various quality control statistics for long read pass *and* fail data where `<SAMPLE>` = sample 1 or sample4.      |



#### 4. Command Descriptions
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission 
- ``--fastq <MERGED_LONGREADS.fastq.gz>`` = Long reads input file
- ``--plots dot`` = Dot plots for quality metrics included in quality report.
- ``-o <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/reads_qc/longread`*


```{bash}
NanoPlot \
-t $SLURM_CPUS_PER_TASK \
--fastq <MERGED_LONGREADS.fastq.gz> \
--plots dot \
--outdir $OUTDIR
```



