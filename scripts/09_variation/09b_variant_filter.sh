#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=75g
#SBATCH --time=02:00:00
#SBATCH --job-name=09b_variant_filter
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 23.04.2026
## Description: Script to filter variants from VCF files created in script 09a_variant_calling:
#               1. Concatenate 'per chromosome' VCF files into merged VCF
#               2. Filter merged VCF
#               3. Filter to retain only biallelic SNPs
## Usage: Execute from script directory

## Software used:
#  bcftools = (purpose) concatenate VCF files and filter to retain only biallelic SNPs
#  vcftools = (purpose) filter VCF data

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
SCRIPT=${PROJECT_ROOT}/scripts/09_variation/09b_variant_filter.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_alignment

# Load bcftools module
module load bcftools-uoneasy/1.19-GCC-13.2.0 

# Load samples into an array
mapfile -t SAMPLES < "${PROJECT_ROOT}/sample_list.txt"

# Get the current sample based on SLURM_ARRAY_TASK_ID
# Task ID '0' = Sample 1
# Task ID '1' = Sample 4
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}


# Define output directory for VCF stats
OUTDIR_STATS="${PROJECT_ROOT}/results/${SAMPLE}/variants/Haloferax/stats"

# Create output directory
printf "\n$(date): Creating VCF statistics output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_STATS"
printf "\n$(date): Creating VCF statistics output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# 1. Concatenate 'per chromosome' VCF files

# Define output directory 
OUTDIR_CONCAT="${PROJECT_ROOT}/data/processed/${SAMPLE}/variant/Haloferax/merged"

# Create output directory
printf "\n$(date): Creating merged VCF output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_CONCAT"
printf "\n$(date): Creating merged VCF output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define TXT file for chromosome VCF paths
VCF_LIST="${PROJECT_ROOT}/data/processed/${SAMPLE}/variant/${SAMPLE}_vcf_list.txt"

# Write chromosome VCF paths to TXT file
# Find files with size greater than 1kb so that empty VCF files aren't included in TXT file
find ${PROJECT_ROOT}/data/processed/${SAMPLE}/variant/Haloferax/chromosomes/${SAMPLE}_*.vcf.gz -type f -size +1k > "$VCF_LIST"

# Define output file (merged VCF)
VCF_MERGED="$OUTDIR_CONCAT/${SAMPLE}_merged.vcf.gz"

# Concatenate chromosome VCF files into a single merged VCF file
bcftools \
concat \
--file-list "$VCF_LIST" \
-Oz \
--output "$VCF_MERGED"

# Index merged VCF files
bcftools index "$VCF_MERGED"



# 2. Filter merged VCF

# Define output directory for filtered VCF
OUTDIR_FILTER="${PROJECT_ROOT}/data/processed/${SAMPLE}/variant/Haloferax/filtered"


# Create output directory
printf "\n$(date): Creating filtered VCF output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_FILTER"
printf "\n$(date): Creating filtered VCF output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define output file (filtered merged VCF)
VCF_FILTERED="$OUTDIR_FILTER/${SAMPLE}_merged_filtered_q20.vcf.gz"

# Set filters
# Quality filter
QUAL=20

# Depth filter
MIN_DEPTH=2
MAX_DEPTH=50

# Count number of SNPs in raw merged VCF
bcftools view -H "$VCF_MERGED" | wc -l > "$OUTDIR_STATS/${SAMPLE}_merged.vcf.gz.SNPS.txt"


# Use vcftools to filter data
vcftools \
--gzvcf "$VCF_MERGED" \
--minQ "$QUAL" \
--minDP "$MIN_DEPTH" \
--maxDP "$MAX_DEPTH" \
--recode --stdout | bgzip -c > "$VCF_FILTERED"


# Index
bcftools index "$VCF_FILTERED"

# Count number of SNPs in filtered merged VCF
bcftools view -H "$VCF_FILTERED" | wc -l > "$OUTDIR_STATS/${SAMPLE}_merged_filtered_q20.vcf.gz.SNPS.txt"





# 3. Retain only biallelic SNPs

# Define output directory for merged filtered VCF containing only biallelic SNPs
OUTDIR_BSNPS="${PROJECT_ROOT}/data/processed/${SAMPLE}/variant/Haloferax/bSNP"


# Create output directory
printf "\n$(date): Creating filtered VCF (biallelic SNPs only) output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_BSNPS"
printf "\n$(date): Creating filtered VCF (biallelic SNPs only) output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define output file (filtered merged VCF containing only SNPs)
VCF_FILTERED_BSNP="$OUTDIR_BSNPS/${SAMPLE}_merged_filtered_q20b.vcf.gz"

# Run bcftools
bcftools view \
-Oz \
--max-alleles 2 \
-o "$VCF_FILTERED_BSNP" \
"$VCF_FILTERED"

# Index
bcftools index "$VCF_FILTERED_BSNP"

# Count number of SNPs in filtered merged VCF (biallelic SNPs only)
bcftools view -H "$VCF_FILTERED_BSNP" | wc -l > "$OUTDIR_STATS/${SAMPLE}_merged_filtered_q20b.vcf.gz.SNPS.txt"


# deactivate conda environment
conda deactivate 

# Unload module
module unload bcftools-uoneasy/1.19-GCC-13.2.0 
