#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=75g
#SBATCH --time=06:00:00
#SBATCH --job-name=08_alignment
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 22.04.2026
## Description: Script to perform alignment of short read, long read and hybrid assemblies to the reference genome
## Usage: Execute from script directory

## Software used:
#  Minimap2 = (purpose) perform alignment
#  Samtools = (purpose) create assembly index file and BAM alignment file

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
SCRIPT=${PROJECT_ROOT}/scripts/08_alignment/08_alignment.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_assembly

# Load samples into an array
mapfile -t SAMPLES < "${PROJECT_ROOT}/sample_list.txt"

# Get the current sample based on SLURM_ARRAY_TASK_ID
# Task ID '0' = Sample 1
# Task ID '1' = Sample 4
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

# Define reference assembly (Haloferax volcanii)
REF_ASMBLY="${PROJECT_ROOT}/data/reference/genome_assembly/GCF_000025685.1_ASM2568v1_genomic.fna.gz"



# 1. Short read alignment

# Define output directory 
OUTDIR_SHORT="${PROJECT_ROOT}/data/processed/${SAMPLE}/aligned/shortread"

# Create output directory
printf "\n$(date): Creating short read alignment output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_SHORT"
printf "\n$(date): Creating short read alignment output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (polished short read assembly)
SHORT_ASMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_2/${SAMPLE}_shortread_polished_round_2.fasta"

# Align short read assembly to reference genome
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-ax asm5 "$REF_ASMBLY" "$SHORT_ASMBLY" \
| samtools view -b \
| samtools sort -o "$OUTDIR_SHORT/${SAMPLE}_shortread_assembly_to_Haloferax.sort.bam"

# Index BAM file 
samtools index "$OUTDIR_SHORT/${SAMPLE}_shortread_assembly_to_Haloferax.sort.bam"



# 2. Long read alignment

# Define output directory 
OUTDIR_LONG="${PROJECT_ROOT}/data/processed/${SAMPLE}/aligned/longread"

# Create output directory
printf "\n$(date): Creating long read alignment output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_LONG"
printf "\n$(date): Creating long read alignment output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (polished long read assembly)
LONG_ASMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_4/${SAMPLE}_longread_polished_round_4.fasta"

# Align long read assembly to reference genome
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-ax asm5 "$REF_ASMBLY" "$LONG_ASMBLY" \
| samtools view -b \
| samtools sort -o "$OUTDIR_LONG/${SAMPLE}_longread_assembly_to_Haloferax.sort.bam"

# Index BAM file 
samtools index "$OUTDIR_LONG/${SAMPLE}_longread_assembly_to_Haloferax.sort.bam"




# 3. Hybrid alignment

# Define output directory 
OUTDIR_HYBRID="${PROJECT_ROOT}/data/processed/${SAMPLE}/aligned/hybrid"

# Create output directory
printf "\n$(date): Creating hybrid alignment output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_HYBRID"
printf "\n$(date): Creating hybrid alignment output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (polished hybrid assembly)
HYBRID_ASMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_4/${SAMPLE}_hybrid_polished_round_4.fasta"

# Align hybrid assembly to reference genome
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-ax asm5 "$REF_ASMBLY" "$HYBRID_ASMBLY" \
| samtools view -b \
| samtools sort -o "$OUTDIR_HYBRID/${SAMPLE}_hybrid_assembly_to_Haloferax.sort.bam"

# Index BAM file 
samtools index "$OUTDIR_HYBRID/${SAMPLE}_hybrid_assembly_to_Haloferax.sort.bam"



# deactivate conda environment
conda deactivate 
