## Script 
04_de_novo_assembly

### Purpose
Script to produce de novo short read (Illumina), long read (Nanopore) and hybrid genome assemblies.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/04_assembly
```

2. Execute script

```{bash}
sbatch 04_de_novo_assembly.sh
```



### Overview
#### 1. Software
- Unicycler v0.5.1


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_longread` | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore **merged** long reads (pass and fail data) where `<SAMPLE>` = sample 1 or sample4.    |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_shortread_assembly` | .fasta  | FASTA file containing shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_longread_assembly` | .fasta  | FASTA file containing longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_hybrid_assembly` | .fasta  | FASTA file containing hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |


#### 4. Command Descriptions

1. Short read assembly

- ``-1 <MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``-2 <MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``-o <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/data/processed/<SAMPLE>/assembly/shortread`*
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.

```{bash}
unicycler \
-1 <MERGED_SHORTREADS_R1.fastq.gz> \
-2 <MERGED_SHORTREADS_R2.fastq.gz> \
-o <OUTDIR> \
--threads $SLURM_CPUS_PER_TASK
```


2. Long read assembly

- ``-l <MERGED_LONGREADS.fastq.gz>`` = Long reads input file
- ``-o <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/data/processed/<SAMPLE>/assembly/longread`*
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.

```{bash}
unicycler \
-l <MERGED_LONGREADS.fastq.gz> \
-o "$OUTDIR_LONG" \
--threads $SLURM_CPUS_PER_TASK
```



3. Hybrid assembly

- ``-1 <MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``-2 <MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``-l <MERGED_LONGREADS.fastq.gz>`` = Long reads input file
- ``-o <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/data/processed/<SAMPLE>/assembly/hybrid`*
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.

```{bash}
unicycler \
-1 <MERGED_SHORTREADS_R1.fastq.gz> \
-2 <MERGED_SHORTREADS_R2.fastq.gz> \
-l <MERGED_LONGREADS.fastq.gz> \
-o <OUTDIR> \
--threads $SLURM_CPUS_PER_TASK
```

