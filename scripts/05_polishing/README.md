## Script 
05a_polish_shortread

### Purpose
Script to polish de novo short read (Illumina) genome assemblies with raw short reads. Polishing is repeated for two rounds to improve results. PCR duplicates are removed from short reads prior to polishing.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/05_polishing
```

2. Execute script

```{bash}
sbatch 05a_polish_shortread
```



### Overview
#### 1. Software
- Picard v2.20.4
- Bwa v0.7.19
- Samtools v1.23
- Pilon v1.24


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_shortread_assembly` | .fasta  | None-zipped FASTA file containing shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.     |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta  | None-zipped FASTA file containing the polished shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta.amb  | Index file for shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 of polishing.    |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta.ann  | Index file for shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 of polishing.    |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta.bwt  | Index file for shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 of polishing.    |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta.fai  | Index file for shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 of polishing.    |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta.pac  | Index file for shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 of polishing.    |
| `<SAMPLE>_shortread_polished_<ROUND>` | .fasta.sa  | Index file for shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 of polishing.    |
| `<SAMPLE>_shortread_<ROUND>` | .rmd.bam  | BAM file with PCR duplicates removed containing the alignment of merged shortreads (R1 and R2) to the de novo shortread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      |
| `<SAMPLE>_shortread_<ROUND>` | .rmd.bam.bai  | Index BAM file where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      |
| `<SAMPLE>_shortread_<ROUND>` | .rmd.bam.metrics  | Metrics for BAM file where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      |


#### 4. Command Descriptions

1. Index **raw** assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <SHORTREAD_ASSEMBLY.fasta> 
samtools faidx <SHORTREAD_ASSEMBLY.fasta>
```


2. Align short reads to **raw** short read assembly
- ``bwa mem`` = Perform alignment.
- ``-M`` = Allows downstream duplicate removal with Picard.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``<SHORTREAD_ASSEMBLY.fasta>`` = Raw shortread assembly file
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
<SHORTREAD_ASSEMBLY.fasta> \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
| samtools view -b \
| samtools sort -o <SHORTREAD_ALIGNED_ROUND_1.sort.bam>
```


3. Remove PCR duplicates from **round 1** BAM and index

- ``MarkDuplicates`` = Identifies duplicates.
- ``REMOVE_DUPLICATES=true`` = Removes duplicates.
- ``ASSUME_SORTED=true`` = Assumes sorted BAM.
- ``VALIDATION_STRINGENCY=SILENT`` = Ignore warnings and proceed.
- ``MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000`` = Limits simultaneous temporary files to 1000.
- ``INPUT=<SHORTREAD_ALIGNED_ROUND_1.sort.bam>`` = Round 1 sorted BAM input file.
- ``OUTPUT=<SHORTREAD_ALIGNED_ROUND_1.rmd.bam> `` = Round 1 output BAM file with duplicates removed.
- ``METRICS_FILE=<SHORTREAD_ALIGNED_ROUND_1.rmd.bam.metrics> `` = Output metrics file.


```{bash}
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=<SHORTREAD_ALIGNED_ROUND_1.sort.bam> \
OUTPUT=<SHORTREAD_ALIGNED_ROUND_1.rmd.bam> \
METRICS_FILE=<SHORTREAD_ALIGNED_ROUND_1.rmd.bam.metrics> 

samtools index <SHORTREAD_ALIGNED_ROUND_1.rmd.bam>
```


4. Perform **round 1** polishing

- ``--genome <SHORTREAD_ASSEMBLY.fasta>`` = Raw shortread assembly input file.
- ``--bam <SHORTREAD_ALIGNED_ROUND_1.rmd.bam>`` = BAM input file containing raw shortreads aligned to raw shortread assembly.
- ``-outdir <OUTDIR>`` = Path to output directory for the polished shortread assembly: *`PROJECT_ROOT/data/processed/<SAMPLE>/polished/shortread/round_1`*


```{bash}
pilon \
--genome <SHORTREAD_ASSEMBLY.fasta>  \
--bam <SHORTREAD_ALIGNED_ROUND_1.rmd.bam> \
--outdir <OUTDIR>
```


5. Index **round 1** polished assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> 
samtools faidx <SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta>
```


6. Align short reads to **round 1** polished assembly
- ``bwa mem`` = Perform alignment.
- ``-M`` = Allows downstream duplicate removal with Picard.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``<SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Raw shortread assembly file
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
<SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
| samtools view -b \
| samtools sort -o <SHORTREAD_ALIGNED_ROUND_2.sort.bam>
```


7. Remove PCR duplicates from **round 2** BAM and index

- ``MarkDuplicates`` = Identifies duplicates.
- ``REMOVE_DUPLICATES=true`` = Removes duplicates.
- ``ASSUME_SORTED=true`` = Assumes sorted BAM.
- ``VALIDATION_STRINGENCY=SILENT`` = Ignore warnings and proceed.
- ``MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000`` = Limits simultaneous temporary files to 1000.
- ``INPUT=<SHORTREAD_ALIGNED_ROUND_2.sort.bam>`` = Round 2 sorted BAM input file.
- ``OUTPUT=<SHORTREAD_ALIGNED_ROUND_2.rmd.bam> `` = Round 2 output BAM file with duplicates removed.
- ``METRICS_FILE=<SHORTREAD_ALIGNED_ROUND_2.rmd.bam.metrics> `` = Output metrics file.


```{bash}
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=<SHORTREAD_ALIGNED_ROUND_2.sort.bam> \
OUTPUT=<SHORTREAD_ALIGNED_ROUND_2.rmd.bam> \
METRICS_FILE=<SHORTREAD_ALIGNED_ROUND_2.rmd.bam.metrics> 

samtools index <SHORTREAD_ALIGNED_ROUND_2.rmd.bam>
```


8. Perform **round 2** polishing

- ``--genome <SHORTREAD_ASSEMBLY.fasta>`` = Raw shortread assembly input file.
- ``--bam <SHORTREAD_ALIGNED_ROUND_2.rmd.bam>`` = BAM input file containing raw shortreads aligned to raw shortread assembly.
- ``-outdir <OUTDIR>`` = Path to output directory for the polished shortread assembly: *`PROJECT_ROOT/data/processed/<SAMPLE>/polished/shortread/round_2`*


```{bash}
pilon \
--genome <SHORTREAD_ASSEMBLY_POLISHED_ROUND_1.fasta>  \
--bam <SHORTREAD_ALIGNED_ROUND_2.rmd.bam> \
--outdir <OUTDIR>
```



9. Index **round 2** polished assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta> 
samtools faidx <SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>
```


## Script 
05b_polish_longread

### Purpose
Script to polish de novo long read (Nanopore) genome assemblies with raw short and long reads. Polishing is repeated for two rounds each with short and long reads to improve results. PCR duplicates are removed from short reads prior to polishing.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/05_polishing
```

2. Execute script

```{bash}
sbatch 05b_polish_longread
```



### Overview
#### 1. Software
- Picard v2.20.4
- Bwa v0.7.19
- Minimap2 2.30
- Samtools v1.23
- Pilon v1.24
- Racon v1.5.0


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_longread_assembly` | .fasta  | None-zipped FASTA file containing longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_longread` | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore **merged** long reads (pass and fail data) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.     |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta  | None-zipped FASTA file containing the polished longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 or round 3 or round 4 of polishing.      |
| `<SAMPLE>_longread_<ROUND>` | .paf  | Alignment file containing longreads aligned to the longread assembly de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta.amb  | Index file for longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta.ann  | Index file for longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta.bwt  | Index file for longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta.fai  | Index file for longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta.pac  | Index file for longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_longread_polished_<ROUND>` | .fasta.sa  | Index file for longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_longread_<ROUND>` | .rmd.bam  | BAM file with PCR duplicates removed containing the alignment of merged longreads to the de novo longread assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 3 or round 4 of polishing.      |
| `<SAMPLE>_longread_<ROUND>` | .rmd.bam.bai  | Index BAM file where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 3 or round 4 of polishing.      |
| `<SAMPLE>_longread_<ROUND>` | .rmd.bam.metrics  | Metrics for BAM file where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 3 or round 4 of polishing.      |


#### 4. Command Descriptions
1. Align long reads to **raw** long read assembly

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``-x map-ont`` = Preset for Oxford Nanopore read alignment to assembly.

```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-x map-ont <LONGREAD_ASSEMBLY.fasta> <MERGED_LONGREADS.fastq.gz> > <LONGREAD_ALIGNED_ROUND_1.paf>
```


2. Perform **round 1** polishing

```{bash}
racon <MERGED_LONGREADS.fastq.gz> <LONGREAD_ALIGNED_ROUND_1.paf> <LONGREAD_ASSEMBLY.fasta> > <LONGREAD_ASSEMBLY_POLISHED_ROUND_1.fasta>
```

3. Align long reads to **round 1** long read assembly

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``-x map-ont`` = Preset for Oxford Nanopore read alignment to assembly.

```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-x map-ont <LONGREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> <MERGED_LONGREADS.fastq.gz> > <LONGREAD_ALIGNED_ROUND_2.paf>
```


4. Perform **round 2** polishing

```{bash}
racon <MERGED_LONGREADS.fastq.gz> <LONGREAD_ALIGNED_ROUND_2.paf> <LONGREAD_ASSEMBLY_POLISHED_ROUND_1.fasta> > <LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>
```


5. Index **round 2** long read assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>
samtools faidx <LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>
```


6. Align short reads to **round 2** long read assembly
- ``bwa mem`` = Perform alignment.
- ``-M`` = Allows downstream duplicate removal with Picard.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 longread assembly file
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta> \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
| samtools view -b \
| samtools sort -o <LONGREAD_ALIGNED_ROUND_3.sort.bam>
```


7. Remove PCR duplicates from **round 3** BAM and index

- ``MarkDuplicates`` = Identifies duplicates.
- ``REMOVE_DUPLICATES=true`` = Removes duplicates.
- ``ASSUME_SORTED=true`` = Assumes sorted BAM.
- ``VALIDATION_STRINGENCY=SILENT`` = Ignore warnings and proceed.
- ``MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000`` = Limits simultaneous temporary files to 1000.
- ``INPUT=<LONGREAD_ALIGNED_ROUND_3.sort.bam>`` = Round 3 sorted BAM input file.
- ``OUTPUT=<LONGREAD_ALIGNED_ROUND_3.rmd.bam> `` = Round 3 output BAM file with duplicates removed.
- ``METRICS_FILE=<LONGREAD_ALIGNED_ROUND_3.rmd.bam.metrics> `` = Output metrics file.


```{bash}
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=<LONGREAD_ALIGNED_ROUND_3.sort.bam> \
OUTPUT=<LONGREAD_ALIGNED_ROUND_3.rmd.bam> \
METRICS_FILE=<LONGREAD_ALIGNED_ROUND_3.rmd.bam.metrics> 

samtools index <LONGREAD_ALIGNED_ROUND_3.rmd.bam>
```


8. Perform **round 3** polishing

- ``--genome <LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 longread assembly input file.
- ``--bam <LONGREAD_ALIGNED_ROUND_3.rmd.bam>`` = BAM input file containing raw shortreads aligned to round 2 longread assembly.
- ``-outdir <OUTDIR>`` = Path to output directory for the polished longread assembly: *`PROJECT_ROOT/data/processed/<SAMPLE>/polished/longread/round_3`*


```{bash}
pilon \
--genome <LONGREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>  \
--bam <LONGREAD_ALIGNED_ROUND_3.rmd.bam> \
--outdir <OUTDIR>
```


9. Index **round 3** polished long read assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta> 
samtools faidx <LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta>
```


10. Align short reads to **round 3** polished long read assembly
- ``bwa mem`` = Perform alignment.
- ``-M`` = Allows downstream duplicate removal with Picard.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta>`` = Round 3 longread assembly file
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
<LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta> \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
| samtools view -b \
| samtools sort -o <LONGREAD_ALIGNED_ROUND_4.sort.bam>
```


11. Remove PCR duplicates from **round 4** BAM and index

- ``MarkDuplicates`` = Identifies duplicates.
- ``REMOVE_DUPLICATES=true`` = Removes duplicates.
- ``ASSUME_SORTED=true`` = Assumes sorted BAM.
- ``VALIDATION_STRINGENCY=SILENT`` = Ignore warnings and proceed.
- ``MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000`` = Limits simultaneous temporary files to 1000.
- ``INPUT=<LONGREAD_ALIGNED_ROUND_4.sort.bam>`` = Round 4 sorted BAM input file.
- ``OUTPUT=<LONGREAD_ALIGNED_ROUND_4.rmd.bam> `` = Round 4 output BAM file with duplicates removed.
- ``METRICS_FILE=<LONGREAD_ALIGNED_ROUND_4.rmd.bam.metrics> `` = Output metrics file.


```{bash}
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=<LONGREAD_ALIGNED_ROUND_4.sort.bam> \
OUTPUT=<LONGREAD_ALIGNED_ROUND_4.rmd.bam> \
METRICS_FILE=<LONGREAD_ALIGNED_ROUND_4.rmd.bam.metrics> 

samtools index <LONGREAD_ALIGNED_ROUND_4.rmd.bam>
```


12. Perform **round 4** polishing

- ``--genome <LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta>>`` = Round 3 longread assembly input file.
- ``--bam <LONGREAD_ALIGNED_ROUND_4.rmd.bam>`` = BAM input file containing raw shortreads aligned to round 3 longread assembly.
- ``-outdir <OUTDIR>`` = Path to output directory for the polished longread assembly: *`PROJECT_ROOT/data/processed/<SAMPLE>/polished/longread/round_4`*


```{bash}
pilon \
--genome <LONGREAD_ASSEMBLY_POLISHED_ROUND_3.fasta>  \
--bam <LONGREAD_ALIGNED_ROUND_4.rmd.bam> \
--outdir <OUTDIR>
```



13. Index **round 4** polished long read assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta> 
samtools faidx <LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta>
```




## Script 
05c_polish_hybrid

### Purpose
Script to polish de novo hybrid (Illumina/Nanopore) genome assemblies with raw short and long reads. Polishing is repeated for two rounds each with short and long reads to improve results. PCR duplicates are removed from short reads prior to polishing.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/05_polishing
```

2. Execute script

```{bash}
sbatch 05c_polish_hybrid
```



### Overview
#### 1. Software
- Picard v2.20.4
- Bwa v0.7.19
- Minimap2 2.30
- Samtools v1.23
- Pilon v1.24
- Racon v1.5.0


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_hybrid_assembly` | .fasta  | None-zipped FASTA file containing hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_longread` | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore **merged** long reads (pass and fail data) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.    |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.     |


#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta  | None-zipped FASTA file containing the polished hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 or round 3 or round 4 of polishing.      |
| `<SAMPLE>_hybrid_<ROUND>` | .paf  | Alignment file containing long reads aligned to the hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 1 or round 2 of polishing.      
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta.amb  | Index file for hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta.ann  | Index file for hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta.bwt  | Index file for hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta.fai  | Index file for hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta.pac  | Index file for hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_hybrid_polished_<ROUND>` | .fasta.sa  | Index file for hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = raw assembly or round 1 or round 2 or round 3 or round 4 of polishing.    |
| `<SAMPLE>_hybrid_<ROUND>` | .rmd.bam  | BAM file with PCR duplicates removed containing the alignment of merged short reads to the de novo hybrid assembly where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 3 or round 4 of polishing.      |
| `<SAMPLE>_hybrid_<ROUND>` | .rmd.bam.bai  | Index BAM file where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 3 or round 4 of polishing.      |
| `<SAMPLE>_hybrid_<ROUND>` | .rmd.bam.metrics  | Metrics for BAM file where `<SAMPLE>` = sample 1 or sample4 and `<ROUND>` = round 3 or round 4 of polishing.      |


#### 4. Command Descriptions
1. Align long reads to **raw** hybrid assembly

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``-x map-ont`` = Preset for Oxford Nanopore read alignment to assembly.

```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-x map-ont <HYBRID_ASSEMBLY.fasta> <MERGED_LONGREADS.fastq.gz> > <HYBRID_ALIGNED_ROUND_1.paf>
```


2. Perform **round 1** polishing

```{bash}
racon <MERGED_LONGREADS.fastq.gz> <HYBRID_ALIGNED_ROUND_1.paf> <HYBRID_ASSEMBLY.fasta> > <HYBRID_ASSEMBLY_POLISHED_ROUND_1.fasta>
```


3. Align long reads to **round 1** hybrid assembly

- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``-x map-ont`` = Preset for Oxford Nanopore read alignment to assembly.

```{bash}
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-x map-ont <HYBRID_ASSEMBLY_POLISHED_ROUND_1.fasta> <MERGED_LONGREADS.fastq.gz> > <HYBRID_ALIGNED_ROUND_2.paf>
```


4. Perform **round 2** polishing

```{bash}
racon <MERGED_LONGREADS.fastq.gz> <HYBRID_ALIGNED_ROUND_2.paf> <HYBRID_ASSEMBLY_POLISHED_ROUND_1.fasta> > <HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>
```


5. Index **round 2** hybrid assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>
samtools faidx <HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>
```


6. Align short reads to **round 2** hybrid assembly
- ``bwa mem`` = Perform alignment.
- ``-M`` = Allows downstream duplicate removal with Picard.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 hybrid assembly file
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
<HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta> \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
| samtools view -b \
| samtools sort -o <HYBRID_ALIGNED_ROUND_3.sort.bam>
```


7. Remove PCR duplicates from **round 3** BAM and index

- ``MarkDuplicates`` = Identifies duplicates.
- ``REMOVE_DUPLICATES=true`` = Removes duplicates.
- ``ASSUME_SORTED=true`` = Assumes sorted BAM.
- ``VALIDATION_STRINGENCY=SILENT`` = Ignore warnings and proceed.
- ``MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000`` = Limits simultaneous temporary files to 1000.
- ``INPUT=<HYBRID_ALIGNED_ROUND_3.sort.bam>`` = Round 3 sorted BAM input file.
- ``OUTPUT=<HYBRID_ALIGNED_ROUND_3.rmd.bam> `` = Round 3 output BAM file with duplicates removed.
- ``METRICS_FILE=<HYBRID_ALIGNED_ROUND_3.rmd.bam.metrics> `` = Output metrics file.


```{bash}
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=<HYBRID_ALIGNED_ROUND_3.sort.bam> \
OUTPUT=<HYBRID_ALIGNED_ROUND_3.rmd.bam> \
METRICS_FILE=<HYBRID_ALIGNED_ROUND_3.rmd.bam.metrics> 

samtools index <HYBRID_ALIGNED_ROUND_3.rmd.bam>
```


8. Perform **round 3** polishing

- ``--genome <HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Round 2 hybrid assembly input file.
- ``--bam <HYBRID_ALIGNED_ROUND_3.rmd.bam>`` = BAM input file containing raw shortreads aligned to round 2 hybrid assembly.
- ``-outdir <OUTDIR>`` = Path to output directory for the polished hybrid assembly: *`PROJECT_ROOT/data/processed/<SAMPLE>/polished/hybrid/round_3`*


```{bash}
pilon \
--genome <HYBRID_ASSEMBLY_POLISHED_ROUND_2.fasta>  \
--bam <HYBRID_ALIGNED_ROUND_3.rmd.bam> \
--outdir <OUTDIR>
```


9. Index **round 3** polished hybrid assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta> 
samtools faidx <HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta>
```


10. Align short reads to **round 3** polished hybrid assembly
- ``bwa mem`` = Perform alignment.
- ``-M`` = Allows downstream duplicate removal with Picard.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta>`` = Round 3 hybrid assembly file
- ``<MERGED_SHORTREADS_R1.fastq.gz>`` = R1 reads input file
- ``<MERGED_SHORTREADS_R2.fastq.gz>`` = R2 reads input file
- ``view -b`` = Outputs in BAM format
- ``sort -o`` = Sorts and outputs BAM file


```{bash}
bwa mem \
-M \
-t $SLURM_CPUS_PER_TASK \
<HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta> \
<MERGED_SHORTREADS_R1.fastq.gz> \
<MERGED_SHORTREADS_R2.fastq.gz> \
| samtools view -b \
| samtools sort -o <HYBRID_ALIGNED_ROUND_4.sort.bam>
```


11. Remove PCR duplicates from **round 4** BAM and index

- ``MarkDuplicates`` = Identifies duplicates.
- ``REMOVE_DUPLICATES=true`` = Removes duplicates.
- ``ASSUME_SORTED=true`` = Assumes sorted BAM.
- ``VALIDATION_STRINGENCY=SILENT`` = Ignore warnings and proceed.
- ``MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000`` = Limits simultaneous temporary files to 1000.
- ``INPUT=<HYBRID_ALIGNED_ROUND_4.sort.bam>`` = Round 4 sorted BAM input file.
- ``OUTPUT=<HYBRID_ALIGNED_ROUND_4.rmd.bam> `` = Round 4 output BAM file with duplicates removed.
- ``METRICS_FILE=<HYBRID_ALIGNED_ROUND_4.rmd.bam.metrics> `` = Output metrics file.


```{bash}
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=<HYBRID_ALIGNED_ROUND_4.sort.bam> \
OUTPUT=<HYBRID_ALIGNED_ROUND_4.rmd.bam> \
METRICS_FILE=<HYBRID_ALIGNED_ROUND_4.rmd.bam.metrics> 

samtools index <HYBRID_ALIGNED_ROUND_4.rmd.bam>
```


12. Perform **round 4** polishing

- ``--genome <HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta>`` = Round 3 hybrid assembly input file.
- ``--bam <HYBRID_ALIGNED_ROUND_4.rmd.bam>`` = BAM input file containing raw shortreads aligned to round 3 hybrid assembly.
- ``-outdir <OUTDIR>`` = Path to output directory for the polished hybrid assembly: *`PROJECT_ROOT/data/processed/<SAMPLE>/polished/hybrid/round_4`*


```{bash}
pilon \
--genome <HYBRID_ASSEMBLY_POLISHED_ROUND_3.fasta>  \
--bam <HYBRID_ALIGNED_ROUND_4.rmd.bam> \
--outdir <OUTDIR>
```



13. Index **round 4** polished hybrid assembly

- ``bwa index`` = Perform indexing using Bwa.
- ``samtools faidx`` = Perform indexing using Samtools.

```{bash}
bwa index <HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta> 
samtools faidx <HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta>
```

