## Script 
09a_variant_calling

### Purpose
Script to identify 'per chromosome' variants between the reference genome and short read, long read and hybrid assemblies:
     1. Create txt file of chromosome names derived from reference genome
     2. Identify variants for Sample 1
     3. Identify variants for Sample 4

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/09_variation
```

2. Execute script

```{bash}
sbatch 09a_variant_calling.sh
```



### Overview
#### 1. Software
- bcftools/1.19-GCC-13.2.0 


#### 2. Input Files
| `<SAMPLE>_<ASSEMBLY>_assembly_to_Haloferax` | .sort.bam  | Sorted BAM file containing the alignment of a given assembly to the Haloferax *volcanii* reference genome where `<SAMPLE>` = sample 1 or sample4 and where `<ASSEMBLY>` = shortread, longread or hybrid.   |



#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_<CHROM>` | .vcf.gz  | Zipped VCF file containing raw variant data for individual chromosomes where `<SAMPLE>` = sample 1 or sample4 and where `<CHROM>` = Haloferax *volcanii* chromosome in RefSeq format: 'NC_013967.1' 'NC_013968.1' 'NC_013965.1' 'NC_013964.1' 'NC_013966.1'   |



#### 4. Command Descriptions

**1. Create 'per chromosome' VCF files**

bcftools mpileup:

- ``mpileup`` = Estimates genotypes.
- ``-t $SLURM_CPUS_PER_TASK`` = Number of threads allocated matches the number of CPUs defined in slurm submission script.
- ``-Ou`` = Output uncompressed to STDOUT
- ``--f <REFERENCE_GENOME.fna>`` = Haloferax *volcanii* reference genome.
- ``--bam-list <PATH_TO_BAM_FILES.txt>`` = File containing paths to short read, long read and hybrid alignment to Haloferax BAM files; each path on separate line. 
- ``--min-MQ 20`` = Excludes reads with mapping quality <20.
- ``--min-BQ 20`` = Excludes reads with base quality <20.
- ``--annotate FORMAT/DP,FORMAT/AD`` = Adds read depth and allele depth information.
- ``-r <CHROMOSOME>`` = Processes chromosomes individually.

bcftools call:
- ``call`` = Identifies variants.
- ``-m`` = Multiallelic variant caller
- ``-v`` = Output variants only.
- ``-a GQ,GP`` = Adds genotype quality and probability annotations.


bcftools norm:
- ``norm`` = Standardises variants.
- ``-m -both`` = Splits multiallelic sites into separate records.
- ``--f <REFERENCE_GENOME.fna>`` = Haloferax *volcanii* reference genome.
- ``-Oz`` = Outputs compressed file.
- ``-o <SAMPLE_CHROM.vcf.gz>`` = VCF output file where `<SAMPLE>` = sample1 or sample4 and `<CHROMOSOME>` = 'NC_013967.1' 'NC_013968.1' 'NC_013965.1' 'NC_013964.1' 'NC_013966.1'.

```{bash}
bcftools mpileup \
--threads $SLURM_CPUS_PER_TASK \
-Ou \
--f <REFERENCE_GENOME.fna> \
--bam-list <PATH_TO_BAM_FILES.txt> \
--min-MQ 20 \
--min-BQ 20 \
--annotate FORMAT/DP,FORMAT/AD \
-r <CHROMOSOME>` \
| bcftools call \
--threads $SLURM_CPUS_PER_TASK \
-m \
-v \
-a GQ,GP \
| bcftools norm \
--threads $SLURM_CPUS_PER_TASK \
-m -both \
-f <REFERENCE_GENOME.fna> \
-Oz \
-o <SAMPLE_CHROMOSOME.vcf.gz>
```



**2. Index VCF files**

```{bash}
bcftools index <SAMPLE_CHROMOSOME.vcf.gz>
```





## Script 
09b_variant_filter

### Purpose
Script to filter variants from VCF files created in script 09a_variant_calling:
1. Concatenate 'per chromosome' VCF files into merged VCF
2. Filter merged VCF
3. Filter to retain only biallelic SNPs

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/09_variation
```

2. Execute script

```{bash}
sbatch 09b_variant_filter.sh
```



### Overview
#### 1. Software
- bcftools/1.19-GCC-13.2.0 
- Vcftools 0.1.17


#### 2. Input Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_<CHROM>` | .vcf.gz  | Zipped VCF file containing raw variant data for individual chromosomes where `<SAMPLE>` = sample 1 or sample4 and where `<CHROM>` = Haloferax *volcanii* chromosome in RefSeq format: 'NC_013967.1' 'NC_013968.1' 'NC_013965.1' 'NC_013964.1' 'NC_013966.1'   |



#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_MERGED` | .vcf.gz  | Zipped VCF file containing **raw** merged variant data for **all** chromosomes where `<SAMPLE>` = sample 1 or sample4.   |
| `<SAMPLE>_MERGED_filtered_q20` | .vcf.gz  | Zipped VCF file containing **filtered** merged variant data for **all** chromosomes where `<SAMPLE>` = sample 1 or sample4.   |
| `<SAMPLE>_MERGED_filtered_q20` | .vcf.gz  | Zipped VCF file containing **filtered** merged variant data consisting of only **biallelic SNPs** for **all** chromosomes where `<SAMPLE>` = sample 1 or sample4.   |
| `<SAMPLE>_MERGED` | .vcf.gz.SNPS.txt  | Text file containing the number of variants present **pre-filtering** where `<SAMPLE>` = sample 1 or sample4.   |
| `<SAMPLE>_MERGED_filtered_q20` | .vcf.gz.SNPS.txt  | Text file containing the number of variants present **post-filtering** where `<SAMPLE>` = sample 1 or sample4.   |
| `<SAMPLE>_MERGED_filtered_q20b` | .vcf.gz.SNPS.txt  | Text file containing the number of variants present **post-filtering** and with only **biallelic SNPs** included where `<SAMPLE>` = sample 1 or sample4.   |



#### 4. Command Descriptions

**1. Concatenate 'per chromosome' VCF files**

- ``concat`` = Concatenate VCF files into one merged VCF file.
- ``---file-list <PATH_TO_VCF_FILES.txt>`` = File containing paths to individual chromosome VCF files; each path on separate line.
- ``-Oz`` = Outputs compressed file.
- ``--output <SAMPLE_MERGED.vcf.gz>`` = Concatenated VCF output file where `<SAMPLE>` = sample1 or sample4.

```{bash}
bcftools \
concat \
--file-list <PATH_TO_VCF_FILES.txt> \
-Oz \
--output <SAMPLE_MERGED.vcf.gz>
```



**2. Index merged VCF file**

```{bash}
bcftools index <SAMPLE_MERGED.vcf.gz>
```


**3. Count SNPs in merged raw VCF**

- ``view -H <SAMPLE_MERGED.vcf.gz>`` = Reads the VCF file whilst omitting header lines.
- ``wc -l > <SAMPLE_MERGED.vcf.gz.SNPS.txt>`` = Counts the number of lines (excluding header lines) - one SNP per chromosome therefore the number of lines is equivalent to the number of SNPs - then writes the output to TXT file. 

```{bash}
bcftools view -H <SAMPLE_MERGED.vcf.gz> | wc -l > <SAMPLE_MERGED.vcf.gz.SNPS.txt>
```


**4. Filter merged VCF file**

- ``--gzvcf <SAMPLE_MERGED.vcf.gz>`` = Merged VCF file in gzipped format where `<SAMPLE>` = sample1 or sample4.
- ``--minQ 20`` = Excludes variants with variant quality <20.
- ``--minDP 2`` = Excludes variants with depth \<3.
- ``--maxDP 50`` = Excludes variants with depth >50.
- ``--recode --stdout`` = Direct filtered VCF to stdout.
- ``--bgzip -c`` = Output compressed VCF.

```{bash}
vcftools \
--gzvcf <SAMPLE_MERGED.vcf.gz> \
--minQ 20 \
--minDP 2 \
--maxDP 50 \
--recode --stdout | bgzip -c > <SAMPLE_MERGED_FILTERED.vcf.gz>
```


**5. Index merged filtered VCF file**

```{bash}
bcftools index <SAMPLE_MERGED_FILTERED.vcf.gz>
```


**6. Count SNPs in merged filtered VCF**

- ``view -H <SAMPLE_MERGED_FILTERED.vcf.gz>`` = Reads the VCF file whilst omitting header lines.
- ``wc -l > <SAMPLE_MERGED_FILTERED.vcf.gz.SNPS.txt>`` = Counts the number of lines (excluding header lines) - one SNP per chromosome therefore the number of lines is equivalent to the number of SNPs - then writes the output to TXT file. 

```{bash}
bcftools view -H <SAMPLE_MERGED_FILTERED.vcf.gz> | wc -l > <SAMPLE_MERGED_FILTERED.vcf.gz.SNPS.txt>
```



**7. Retain only biallelic SNPs**

- ``view`` = Reads the VCF file.
- ``-Oz`` = Outputs compressed file.
- ``--max-alleles 2`` = Retain only biallelic SNPs.
- ``-o <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz>`` = VCF output file containing only biallelic SNPs where `<SAMPLE>` = sample1 or sample4.
- ``<SAMPLE_MERGED_FILTERED.vcf.gz>`` = Concatenated VCF input file where `<SAMPLE>` = sample1 or sample4.


```{bash}
bcftools view \
-Oz \
--max-alleles 2 \
-o <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz> \
<SAMPLE_MERGED_FILTERED.vcf.gz>
```


**8. Index merged filtered VCF file**

```{bash}
bcftools index <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz>
```


**9. Count SNPs in merged filtered VCF**

- ``view -H <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz>`` = Reads the VCF file whilst omitting header lines.
- ``wc -l > <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz.SNPS.txt>`` = Counts the number of lines (excluding header lines) - one SNP per chromosome therefore the number of lines is equivalent to the number of SNPs - then writes the output to TXT file. 

```{bash}
bcftools view -H <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz> | wc -l > <SAMPLE_MERGED_FILTERED_BSNP.vcf.gz.SNPS.txt>
```

