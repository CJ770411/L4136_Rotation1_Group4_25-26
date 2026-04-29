## Script 
06_assembly_qc

### Purpose
Script to produce a quality control (QC) report for:
    1. Raw vs polished short read, long read and hybrid genome assemblies. 
    2. Comparison of short read genome assemblies: raw, round 1 polished, round 2 polished.
    3. Comparison of long read genome assemblies: raw, round 1 polished, round 2 polished, round 3 polished, round 4 polished.
    4. Comparison of hybrid genome assemblies: raw, round 1 polished, round 2 polished, round 3 polished, round 4 polished.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/06_assembly_qc
```

2. Execute script

```{bash}
sbatch 06_assembly_qc.sh
```



### Overview
#### 1. Software
- Quast v5.3.0


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_longread` | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore **merged** long reads (pass and fail data) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .gff.gz  | Gzipped annotation for Haloferax *volcanii*.     |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.gz  | Gzipped reference genome for Haloferax *volcanii*.     |
| `<SAMPLE>_longread_assembly` | .fasta  | None-zipped FASTA file containing longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_shortread_assembly` | .fasta  | None-zipped FASTA file containing shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_hybrid_assembly` | .fasta  | None-zipped FASTA file containing hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta  | None-zipped FASTA file containing the polished shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      |
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta  | None-zipped FASTA file containing the polished longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 or round 3 or round 4 of polishing.      |
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta  | None-zipped FASTA file containing the polished hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 or round 3 or round 4 of polishing.      |



#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `report` | .html  | Report containing quality control data for raw short read, long read and hybrid assemblies and at all stages throughout polishing. For short read, long read and hybrid assemblies, the reports are split into 'raw vs final polished' and 'polishing rounds' to examine all stages of polishing.   |



#### 4. Command Descriptions

1. Comparison: **Raw vs Final Polished**

- ``<SHORTREAD_RAW_ASSEMBLY.fasta>`` = Raw short read assembly input file.
- ``<LONGREAD_RAW_ASSEMBLY.fasta>`` = Raw long read assembly input file.
- ``<HYBRID_RAW_ASSEMBLY.fasta>`` = Raw hybrid assembly input file.
- ``<SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Final polished short read assembly input file.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta>`` = Final polished long read assembly input file.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta>`` = Final polished hybrid assembly input file.
- ``-r <REFERENCE_GENOME.fna.gz>`` = Reference genome input file.
- ``-g <REFERENCE_ANNOTATION.gff.gz`` = Reference annotation input file.
- ``-1 <MERGED_SHORTREADS_R1.fastq.gz>`` = Raw merged short reads (R1) input file.
- ``-2 <MERGED_SHORTREADS_R2.fastq.gz>`` = Raw merged short reads (R2) input file.
- ``--nanopore <MERGED_LONGREADS.fastq.gz>`` = Raw merged long reads input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/raw_vs_polished`*

```{bash}
quast \
<SHORTREAD_RAW_ASSEMBLY.fasta> \
<LONGREAD_RAW_ASSEMBLY.fasta> \
<HYBRID_RAW_ASSEMBLY.fasta> \
<SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta> \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta> \
<HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta> \
-r <REFERENCE_GENOME.fna.gz> \
-g <REFERENCE_ANNOTATION.gff.gz \
-1 <MERGED_SHORTREADS_R1.fastq.gz> \
-2 <MERGED_SHORTREADS_R2.fastq.gz> \
--nanopore <MERGED_LONGREADS.fastq.gz> \
-o <OUTDIR>
```


2. Comparison: **Shortread assembly polishing rounds**

- ``<SHORTREAD_RAW_ASSEMBLY.fasta>`` = Raw short read assembly input file.
- ``<SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta>`` = Round 1 polished short read assembly input file.
- ``<SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 (final round) polished short read assembly input file.
- ``-r <REFERENCE_GENOME.fna.gz>`` = Reference genome input file.
- ``-g <REFERENCE_ANNOTATION.gff.gz`` = Reference annotation input file.
- ``-1 <MERGED_SHORTREADS_R1.fastq.gz>`` = Raw merged short reads (R1) input file.
- ``-2 <MERGED_SHORTREADS_R2.fastq.gz>`` = Raw merged short reads (R2) input file.
- ``--nanopore <MERGED_LONGREADS.fastq.gz>`` = Raw merged long reads input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/polishing_rounds/shortread`*

```{bash}
quast \
<SHORTREAD_RAW_ASSEMBLY.fasta> \
<SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> \
<SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta> \
-r <REFERENCE_GENOME.fna.gz> \
-g <REFERENCE_ANNOTATION.gff.gz \
-1 <MERGED_SHORTREADS_R1.fastq.gz> \
-2 <MERGED_SHORTREADS_R2.fastq.gz> \
-o <OUTDIR>
```


3. Comparison: **Longread assembly polishing rounds**

- ``<LONGREAD_RAW_ASSEMBLY.fasta>`` = Raw long read assembly input file.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_1.fasta>`` = Round 1 polished long read assembly input file.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 polished long read assembly input file.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta>`` = Round 3 polished long read assembly input file.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta>`` = Round 4 (final round) polished long read assembly input file.
- ``-r <REFERENCE_GENOME.fna.gz>`` = Reference genome input file.
- ``-g <REFERENCE_ANNOTATION.gff.gz`` = Reference annotation input file.
- ``--nanopore <MERGED_LONGREADS.fastq.gz>`` = Raw merged long reads input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/polishing_rounds/longread`*

```{bash}
quast \
<LONGREAD_RAW_ASSEMBLY.fasta> \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta> \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta> \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta> \
-r <REFERENCE_GENOME.fna.gz> \
-g <REFERENCE_ANNOTATION.gff.gz \
--nanopore <MERGED_LONGREADS.fastq.gz> \
-o <OUTDIR>
```



4. Comparison: **Hybrid assembly polishing rounds**

- ``<HYBRID_RAW_ASSEMBLY.fasta>`` = Raw hybrid assembly input file.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_1.fasta>`` = Round 1 polished hybrid assembly input file.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 polished hybrid assembly input file.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta>`` = Round 3 polished hybrid assembly input file.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta>`` = Round 4 (final round) polished hybrid assembly input file.
- ``-r <REFERENCE_GENOME.fna.gz>`` = Reference genome input file.
- ``-g <REFERENCE_ANNOTATION.gff.gz`` = Reference annotation input file.
- ``-1 <MERGED_SHORTREADS_R1.fastq.gz>`` = Raw merged short reads (R1) input file.
- ``-2 <MERGED_SHORTREADS_R2.fastq.gz>`` = Raw merged short reads (R2) input file.
- ``--nanopore <MERGED_LONGREADS.fastq.gz>`` = Raw merged long reads input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/polishing_rounds/hybrid`*

```{bash}
quast \
<HYBRID_RAW_ASSEMBLY.fasta> \
<HYBRID_ASSEMBLY_POLISHED_ROUND_1.fasta> \
<HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta> \
<HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta> \
<HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta> \
-r <REFERENCE_GENOME.fna.gz> \
-g <REFERENCE_ANNOTATION.gff.gz \
-1 <MERGED_SHORTREADS_R1.fastq.gz> \
-2 <MERGED_SHORTREADS_R2.fastq.gz> \
--nanopore <MERGED_LONGREADS.fastq.gz> \
-o <OUTDIR>
```

