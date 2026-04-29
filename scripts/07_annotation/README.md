## Script 
07a_annotation

### Purpose
Script to perform annotation of short read, long read and hybrid genome assemblies.

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/07_annotation
```

2. Execute script

```{bash}
sbatch 07a_annotation.sh
```



### Overview
#### 1. Software
- Prokka v1.15.6


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_shortread_polished_round_2` | .fasta  | None-zipped FASTA file containing the final polished shortread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_longread_polished_round_4` | .fasta  | None-zipped FASTA file containing the final polished longread de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |
| `<SAMPLE>_hybrid_polished_round_4` | .fasta  | None-zipped FASTA file containing the final polished hybrid de novo genome assembly where `<SAMPLE>` = sample 1 or sample4.      |



#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_<ASSEMBLY>_annotated` | .gff  | Master annotation file in GFF3 format containing both the sequence and the annotation where `<SAMPLE>` = sample 1 or sample4 and where `<ASSEMBLY>` = short read, long read or hybrid.   |
| `<SAMPLE>_<ASSEMBLY>_annotated` | .gbk  | Standard Genbank file which is derived from .gff. This is used to visualise the annotation with Genovi where `<SAMPLE>` = sample 1 or sample4 and where `<ASSEMBLY>` = shortread, longread or hybrid.   |



#### 4. Command Descriptions

**1. Short read annotation**

- ``<SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta>`` = Final polished short read assembly input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/raw_vs_polished`*
- ``--force`` = Overwrites output directory if it already exists.
- ``--prefix <SAMPLE_SHORTREAD_ANNOTATED>`` = Final polished short read assembly input file.
- ``--kingdom Archaea `` = Specify kingdom for Haloferax *volcanii* reference genome.
- ``--genus Haloferax`` = Specify genus for Haloferax *volcanii* reference genome.
- ``--species volcanii`` = Specify species for Haloferax *volcanii* reference genome.
- ``--strain DS2`` = Specify strain for Haloferax *volcanii* reference genome.
- ``--usegenus`` = Specify that the genus-specific database for Haloferax should be used; this improves annotation specificity.

```{bash}
prokka <SHORTREAD_ASSEMBLY_POLISHED_ROUND_2.fasta> \
--outdir <OUTDIR> --force \
--prefix <SAMPLE_SHORTREAD_ANNOTATED> \
--kingdom Archaea \
--genus Haloferax \
--species volcanii \
--strain DS2 \
--usegenus
```


**2. Long read annotation**

- ``<LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta>`` = Final polished long read assembly input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/raw_vs_polished`*
- ``--force`` = Overwrites output directory if it already exists.
- ``--prefix <SAMPLE_LONGREAD_ANNOTATED>`` = Final polished long read assembly input file.
- ``--kingdom Archaea `` = Specify kingdom for Haloferax *volcanii* reference genome.
- ``--genus Haloferax`` = Specify genus for Haloferax *volcanii* reference genome.
- ``--species volcanii`` = Specify species for Haloferax *volcanii* reference genome.
- ``--strain DS2`` = Specify strain for Haloferax *volcanii* reference genome.
- ``--usegenus`` = Specify that the genus-specific database for Haloferax should be used; this improves annotation specificity.

```{bash}
prokka <LONGREAD_ASSEMBLY_POLISHED_ROUND_4.fasta> \
--outdir <OUTDIR> --force \
--prefix <SAMPLE_LONGREAD_ANNOTATED> \
--kingdom Archaea \
--genus Haloferax \
--species volcanii \
--strain DS2 \
--usegenus
```


**3. Hybrid annotation**

- ``<HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta>`` = Final polished hybrid assembly input file.
- ``-outdir <OUTDIR>`` = Path to output directory: *`PROJECT_ROOT/results/<SAMPLE>/assembly/qc/raw_vs_polished`*
- ``--force`` = Overwrites output directory if it already exists.
- ``--prefix <SAMPLE_HYBRID_ANNOTATED>`` = Final polished hybrid assembly input file.
- ``--kingdom Archaea `` = Specify kingdom for Haloferax *volcanii* reference genome.
- ``--genus Haloferax`` = Specify genus for Haloferax *volcanii* reference genome.
- ``--species volcanii`` = Specify species for Haloferax *volcanii* reference genome.
- ``--strain DS2`` = Specify strain for Haloferax *volcanii* reference genome.
- ``--usegenus`` = Specify that the genus-specific database for Haloferax should be used; this improves annotation specificity.

```{bash}
prokka <HYBRID_ASSEMBLY_POLISHED_ROUND_4.fasta> \
--outdir <OUTDIR> --force \
--prefix <SAMPLE_HYBRID_ANNOTATED> \
--kingdom Archaea \
--genus Haloferax \
--species volcanii \
--strain DS2 \
--usegenus
```

## Script 
07b_annotation_visualisation

### Purpose
Script to perform annotation visualisation of:
1. Haloferax volcanii reference assembly
2. Short read genome assembly
3. Long read genome assembly
4. Hybrid genome assembly

### Usage
Execute from scripts directory:
1. Navigate to script directory

```{bash}
cd <PATH_TO_PROJECT_ROOT>/scripts/07_annotation
```

2. Execute script

```{bash}
sbatch 07b_annotation_visualisation.sh
```



### Overview
#### 1. Software
- Genovi v0.4.3


#### 2. Input Files

| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_<ASSEMBLY>_annotated` | .gbk  | Standard Genbank file which is derived from .gff. This is used to visualise the annotation with Genovi where `<SAMPLE>` = sample 1 or sample4 and where `<ASSEMBLY>` = shortread, longread or hybrid.   |
| `GCF_000025685.1_ASM2568v1_genomic` | .gbff.gz  | Gzipped annotation for Haloferax *volcanii*.     |



#### 3. Output Files
| Name              | Extension | Description                                              |
|-------------------|-----------|----------------------------------------------------------|
| `<SAMPLE>_<ANNOTATION>` | .svg  | Image showing key features of annotated assemblies where `<SAMPLE>` = sample 1 or sample4 and where `<ANNOTATION>` = shortread, longread or hybrid assembly annotation.   |
| `reference` | .svg  | Image showing key features of Haloferax *volcani*i reference annotation.   |




#### 4. Command Descriptions

**1. Reference annotation visualisation**

- ``-i <REFERENCE_ANNOTATION.gff.gz>`` = Input annotation file for reference genome.
- ``-s draft`` = Represents assembly as contigs rather than complete chromosome.
- ``-cs autumn`` = Defines theme as 'autumn'.
- ``-bc white`` = Defines background colour as 'white'.
- ``-o reference`` = Defines name of output directory as 'reference'
- ``-te`` = Displays terminal elements e.g. contig ends.
- ``--size`` = Adds size information.
- ``-t "Reference Assembly"`` = Title.

```{bash}
genovi \
-i <REFERENCE_ANNOTATION.gff.gz> \
-s draft \
-cs autumn \
-bc white \
-o reference \
-te \
--size \
-t "Reference Assembly"
```


**2. Short read annotation visualisation**

- ``-i <SHORTREAD_ANNOTATION.gff.gz>`` = Input annotation file for shortread assembly.
- ``-s draft`` = Represents assembly as contigs rather than complete chromosome.
- ``-cs autumn`` = Defines theme as 'autumn'.
- ``-bc white`` = Defines background colour as 'white'.
- ``-o <SAMPLE_SHORTREAD>`` = Defines name of output directory as 'shortread' where `<SAMPLE>` = sample1 or sample4.
- ``-te`` = Displays terminal elements e.g. contig ends.
- ``--size`` = Adds size information.
- ``-t "Short Read Assembly"`` = Title.

```{bash}
genovi \
-i <SHORTREAD_ANNOTATION.gff.gz> \
-s draft \
-cs autumn \
-bc white \
-o <SAMPLE_SHORTREAD> \
-te \
--size \
-t "Short Read Assembly"
```


**3. Long read annotation visualisation**

- ``-i <LONGREAD_ANNOTATION.gff.gz>`` = Input annotation file for longread assembly.
- ``-s draft`` = Represents assembly as contigs rather than complete chromosome.
- ``-cs autumn`` = Defines theme as 'autumn'.
- ``-bc white`` = Defines background colour as 'white'.
- ``-o <SAMPLE_LONGREAD>`` = Defines name of output directory as 'longread' where `<SAMPLE>` = sample1 or sample4.
- ``-te`` = Displays terminal elements e.g. contig ends.
- ``--size`` = Adds size information.
- ``-t "Long Read Assembly"`` = Title.

```{bash}
genovi \
-i <LONGREAD_ANNOTATION.gff.gz> \
-s draft \
-cs autumn \
-bc white \
-o <SAMPLE_LONGREAD> \
-te \
--size \
-t "Long Read Assembly"
```


**4. Hybrid annotation visualisation**

- ``-i <HYBRID_ANNOTATION.gff.gz>`` = Input annotation file for hybrid assembly.
- ``-s draft`` = Represents assembly as contigs rather than complete chromosome.
- ``-cs autumn`` = Defines theme as 'autumn'.
- ``-bc white`` = Defines background colour as 'white'.
- ``-o <SAMPLE_HYBRID>`` = Defines name of output directory as 'hybrid' where `<SAMPLE>` = sample1 or sample4.
- ``-te`` = Displays terminal elements e.g. contig ends.
- ``--size`` = Adds size information.
- ``-t "Hybrid Assembly"`` = Title.

```{bash}
genovi \
-i <HYBRID_ANNOTATION.gff.gz> \
-s draft \
-cs autumn \
-bc white \
-o <SAMPLE_HYBRID> \
-te \
--size \
-t "Hybrid Assembly"
```
