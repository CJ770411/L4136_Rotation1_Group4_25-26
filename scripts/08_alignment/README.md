## Script 
08_alignment

### Purpose
Script to perform alignment of short read, long read and hybrid assemblies to the reference genome.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/08_alignment
```

2. Execute script

```{bash}
sbatch 08_alignment.sh
```



### Overview
#### 1. Software
- Minimap2 2.30
- Samtools v1.23


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_shortread_polished_round_2` | .fasta  | None-zipped FASTA file containing the final polished shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_longread_polished_round_4` | .fasta  | None-zipped FASTA file containing the final polished longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_hybrid_polished_round_4` | .fasta  | None-zipped FASTA file containing the final polished hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `GCF_000025685.1_ASM2568v1_genomic` | .fna.gz  | Gzipped reference genome for Haloferax *volcanii*.     |



#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_<ASSEMBLY>_assembly_to_Haloferax` | .sort.bam  | Sorted BAM file containing the alignment of a given assembly to the Haloferax *volcanii* reference genome where `<SAMPLE>` = sample 1 or sample4 and where `<ASSEMBLY>` = shortread, longread or hybrid.   |




#### 4. Command Descriptions

**1. Short read alignment**

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- `` -ax asm5`` = Preset for assembly-to-assembly alignment and output in SAM format.
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-ax asm5 <REFERENCE_GENOME.fna.gz> <SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> \
| samtools view -b \
| samtools sort -o <SHORTREAD_ALIGNED_TO_HALOFERAX.sort.bam>
```

**2. Index short read alignment**

```{bash}
samtools index <SHORTREAD_ALIGNED_TO_HALOFERAX.sort.bam>
```


**3. Long read alignment**

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- `` -ax asm5`` = Preset for assembly-to-assembly alignment and output in SAM format.
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-ax asm5 <REFERENCE_GENOME.fna.gz> <LONGREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> \
| samtools view -b \
| samtools sort -o <LONGREAD_ALIGNED_TO_HALOFERAX.sort.bam>
```


**4. Index long read alignment**

```{bash}
samtools index <LONGREAD_ALIGNED_TO_HALOFERAX.sort.bam>
```


**5. Hybrid alignment**

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- `` -ax asm5`` = Preset for assembly-to-assembly alignment and output in SAM format.
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-ax asm5 <REFERENCE_GENOME.fna.gz> <HYBRID_ASSEMBLY_POLISHED_ROUND_1.fasta> \
| samtools view -b \
| samtools sort -o <HYBRID_ALIGNED_TO_HALOFERAX.sort.bam>
```


**6. Index hybrid alignment**

```{bash}
samtools index <HYBRID_ALIGNED_TO_HALOFERAX.sort.bam>
```

