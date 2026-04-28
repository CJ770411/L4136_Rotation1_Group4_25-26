#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=20g
#SBATCH --time=04:00:00
#SBATCH --job-name=09a_variant_calling
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-4 # Five chromosomes

##########################

## Author: Chris Janschke
## Date: 23.04.2026
## Description: Script to identify 'per chromosome' variants between the reference genome and short read, long read and hybrid assemblies:
#               1. Create txt file of chromosome names derived from reference genome
#               2. Identify variants for Sample 1
#               3. Identify variants for Sample 4
## Usage: Execute from script directory

## Software used:
#  bcftools = (purpose) perform pileup, variant calling, normalisation and indexing

##########################



# Set error handling
# PARAMETERS:
# -e = Exit immediately
# -o pipefail = Fail pipeline
set -e -o pipefail

# Define project root for downstream navigation
PROJECT_ROOT="$(realpath "${SLURM_SUBMIT_DIR}/../..")" # 2nd Parent directory of script

# Confirm script has been called from the script directory
# and if it hasn't, abandon script execution
SCRIPT=${PROJECT_ROOT}/scripts/09_variation/09a_variant_calling.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Load bcftools module
module load bcftools-uoneasy/1.19-GCC-13.2.0 

# Define reference assembly (Haloferax volcanii)
REF_ASMBLY="${PROJECT_ROOT}/data/reference/genome_assembly/GCF_000025685.1_ASM2568v1_genomic.fna"


## 1. Create TXT file of chromosomes

# Define chromosome TXT file
CHR_LIST="${PROJECT_ROOT}/data/reference/genome_assembly/chr.names.txt"

# Write chromosome names to TXT file
printf "%s\n" "NC_013967.1" "NC_013968.1" "NC_013965.1" "NC_013964.1" "NC_013966.1" > "$CHR_LIST"

# Load chromosomes names into an array
mapfile -t ROOTS < "$CHR_LIST"
CHROM=${ROOTS[$SLURM_ARRAY_TASK_ID]}



## 2. Identify Variants - SAMPLE 1 (S1)

# Define output directory 
OUTDIR_S1="${PROJECT_ROOT}/data/processed/sample1/variant/Haloferax/chromosomes"

# Create output directory
printf "\n$(date): Creating sample 1 'per chromosome' variant output directory for sample1 in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_S1"
printf "\n$(date): Creating sample 1 'per chromosome' variant output directory for sample1 in $SLURM_JOB_NAME: Finished\n\n"

# Retrieve absolute paths to BAM files from assemblies aligned to reference genome
SHORT_BAM_PATH_S1=$(realpath "${PROJECT_ROOT}/data/processed/sample1/aligned/shortread/sample1_shortread_assembly_to_Haloferax.sort.bam")
LONG_BAM_PATH_S1=$(realpath "${PROJECT_ROOT}/data/processed/sample1/aligned/longread/sample1_longread_assembly_to_Haloferax.sort.bam")
HYBRID_BAM_PATH_S1=$(realpath "${PROJECT_ROOT}/data/processed/sample1/aligned/hybrid/sample1_hybrid_assembly_to_Haloferax.sort.bam")

# Define TXT file for BAM paths
BAM_LIST_S1="${PROJECT_ROOT}/data/processed/sample1/aligned/sample1_bam_list.txt"

# Write BAM paths to TXT file
printf "%s\n" "$SHORT_BAM_PATH_S1" "$LONG_BAM_PATH_S1" "$HYBRID_BAM_PATH_S1" > "$BAM_LIST_S1"

# Define output file (per chromosome VCF)
OUTFILE_S1="$OUTDIR_S1"/sample1_${CHROM}.vcf.gz

# Run bcftools to create VCF file
bcftools mpileup \
--threads $SLURM_CPUS_PER_TASK \
-Ou \
-f "$REF_ASMBLY" \
--bam-list "$BAM_LIST_S1" \
--min-MQ 20 \
--min-BQ 20 \
--annotate FORMAT/DP,FORMAT/AD \
-r "$CHROM" \
| bcftools call \
--threads $SLURM_CPUS_PER_TASK \
-m \
-v \
-a GQ,GP \
| bcftools norm \
--threads $SLURM_CPUS_PER_TASK \
-m -both \
-f "$REF_ASMBLY" \
-Oz \
-o "$OUTFILE_S1"

# Index VCF files
bcftools index "$OUTFILE_S1"




## 3. Identify Variants - SAMPLE 4 (S4)

# Define output directory 
OUTDIR_S4="${PROJECT_ROOT}/data/processed/sample4/variant/Haloferax/chromosomes"

# Create output directory
printf "\n$(date): Creating sample 4 'per chromosome' variant output directory for sample4 in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_S4"
printf "\n$(date): Creating sample 4 'per chromosome' variant output directory for sample4 in $SLURM_JOB_NAME: Finished\n\n"

# Retrieve absolute paths to BAM files from assemblies aligned to reference genome
SHORT_BAM_PATH_S4=$(realpath "${PROJECT_ROOT}/data/processed/sample4/aligned/shortread/sample4_shortread_assembly_to_Haloferax.sort.bam")
LONG_BAM_PATH_S4=$(realpath "${PROJECT_ROOT}/data/processed/sample4/aligned/longread/sample4_longread_assembly_to_Haloferax.sort.bam")
HYBRID_BAM_PATH_S4=$(realpath "${PROJECT_ROOT}/data/processed/sample4/aligned/hybrid/sample4_hybrid_assembly_to_Haloferax.sort.bam")

# Define TXT file for BAM paths
BAM_LIST_S4="${PROJECT_ROOT}/data/processed/sample4/aligned/sample4_bam_list.txt"

# Write BAM paths to TXT file
printf "%s\n" "$SHORT_BAM_PATH_S4" "$LONG_BAM_PATH_S4" "$HYBRID_BAM_PATH_S4" > "$BAM_LIST_S4"

# Define output file (per chromosome VCF)
OUTFILE_S4="$OUTDIR_S4"/sample4_${CHROM}.vcf.gz

# Run bcftools to create VCF file
bcftools mpileup \
--threads $SLURM_CPUS_PER_TASK \
-Ou \
-f "$REF_ASMBLY" \
--bam-list "$BAM_LIST_S4" \
--min-MQ 20 \
--min-BQ 20 \
-r "$CHROM" \
| bcftools call \
--threads $SLURM_CPUS_PER_TASK \
-m \
-v \
-a GQ,GP \
--ploidy 1 \
| bcftools norm \
--threads $SLURM_CPUS_PER_TASK \
-m -both \
-f "$REF_ASMBLY" \
-Oz \
-o "$OUTFILE_S4"

# Index VCF files
bcftools index "$OUTFILE_S4"



# Unload module
module unload bcftools-uoneasy/1.19-GCC-13.2.0 
