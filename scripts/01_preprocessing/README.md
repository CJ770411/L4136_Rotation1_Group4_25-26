## Script 
01a_create_sample_list

### Purpose
Script to create "sample_list.txt" containing the samples to be tested in this analysis

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/01_preprocessing
```

2. Execute script

```{bash}
sbatch 01a_create_sample_list.sh
```


### Overview
#### 1. Software
N/A


#### 2. Input Files
N/A


#### 3. Output Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| sample_list | .txt  | Contains '*sample1*' and '*sample4*', each on a new line       |

#### 4. Command Descriptions
- ``printf "%s\n"`` = Writes 'sample1' and 'sample4' on new lines in output .txt file.

```{bash}
printf "%s\n" <sample1 <sample4> > <SAMPLE_LIST.txt>
```




## Script 
01b_merge_raw_reads

### Purpose
Script to merge multiple files of raw short read (Illumina) and long read (Nanopore) sequencing data and save the output in the correct file location and with the correct designation for downstream processing.

### Usage
- ARG1 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R1
- ARG2 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R2
- ARG3 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, pass data
- ARG4 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, fail data
- ARG5 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R1
- ARG6 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R2
- ARG7 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, pass data
- ARG8 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, fail data

Use wildcards to pass multiple of the same file type in each argument. Ensure absolute paths are in quotes if it contains a wildcard e.g.:
``"/abs/path/to/file/H3932_S4_L00*_R1_001.fastq.gz"``

This script is suitable and required for single files in any argument as it is still necessary for these files to be re-named according to the conventions defined within this script to allow downstream processing.

Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/01_preprocessing
```

2. Execute script

```{bash}
sbatch 01b_merge_raw_reads.sh <ARG1> <ARG2> <ARG3> <ARG4> <ARG5> <ARG6> <ARG7> <ARG8>
```


### Overview
#### 1. Software
N/A


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
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_merged_shortread_R1` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R1 (forward reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_shortread_R2` | .fastq.gz  | Gzipped FASTQ file(s) containing **merged** Illumina short read R2 (reverse reads) where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_merged_longread` | .fastq.gz  | Gzipped FASTQ file(s) containing Nanopore **merged** long reads (pass and fail data) where `<SAMPLE>` = sample 1 or sample4.    |


#### 4. Command Descriptions
- ``cat <READS.fastq.gz>`` = Concatenates reads provided in `<READS.fastq.gz>`
- ``> <MERGED_READS.fastq.gz>`` = Directs stdout of `cat` to new file defined as `<MERGED_READS.fastq.gz>`

```{bash}
cat <READS.fastq.gz> > <MERGED_READS.fastq.gz>
```



