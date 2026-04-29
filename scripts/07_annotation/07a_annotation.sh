#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50g
#SBATCH --time=02:00:00
#SBATCH --job-name=07a_annotation
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 22.04.2026
## Description: Script to perform annotation of short read, long read and hybrid genome assemblies.
## Usage: Execute from script directory

## Software used:
#  Prokka = (purpose) perform genome annotation

## Command descriptions:
#  See script README for detailed command description and other useful information.

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
SCRIPT=${PROJECT_ROOT}/scripts/07_annotation/07a_annotation.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_annotation

# Load samples into an array for parallel processing
mapfile -t SAMPLES < "${PROJECT_ROOT}/sample_list.txt"

# Get the current sample based on SLURM_ARRAY_TASK_ID
# Task ID '0' = Sample 1
# Task ID '1' = Sample 4
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}



# 1. Short read annotation

# Define output directory 
OUTDIR_SHORT="${PROJECT_ROOT}/data/processed/${SAMPLE}/annotated/shortread"

# Create output directory
printf "\n$(date): Creating short read assembly annotation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_SHORT"
printf "\n$(date): Creating short read assembly annotation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (polished short read assembly)
SHORT_ASMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_2/${SAMPLE}_shortread_polished_round_2.fasta"

# Initiating Prokka
printf "\n$(date): Running Prokka for short read assembly annotation.\n\n"

# Run Prokka to create annotation
prokka "$SHORT_ASMBLY" \
--outdir "$OUTDIR_SHORT" --force \
--prefix "${SAMPLE}_shortread_annotated" \
--kingdom Archaea \
--genus Haloferax \
--species volcanii \
--strain DS2 \
--usegenus

# Completing Prokka
printf "\n$(date): Completed Prokka for short read assembly annotation.\n\n"




# 2. Long read annotation

# Define output directory 
OUTDIR_LONG="${PROJECT_ROOT}/data/processed/${SAMPLE}/annotated/longread"

# Create output directory
printf "\n$(date): Creating long read assembly annotation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_LONG"
printf "\n$(date): Creating long read assembly annotation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (polished long read assembly)
LONG_ASMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_4/${SAMPLE}_longread_polished_round_4.fasta"

# Initiating Prokka
printf "\n$(date): Running Prokka for long read assembly annotation.\n\n"

# Run Prokka to create annotation
prokka "$LONG_ASMBLY" \
--outdir "$OUTDIR_LONG" --force \
--prefix "${SAMPLE}_longread_annotated" \
--kingdom Archaea \
--genus Haloferax \
--species volcanii \
--strain DS2 \
--usegenus

# Completing Prokka
printf "\n$(date): Completed Prokka for long read assembly annotation.\n\n"




# 3. Hybrid annotation

# Define output directory 
OUTDIR_HYBRID="${PROJECT_ROOT}/data/processed/${SAMPLE}/annotated/hybrid"

# Create output directory
printf "\n$(date): Creating hybrid assembly annotation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_HYBRID"
printf "\n$(date): Creating hybrid assembly annotation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (polished hybrid assembly)
HYBRID_ASMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_4/${SAMPLE}_hybrid_polished_round_4.fasta"

# Initiating Prokka
printf "\n$(date): Running Prokka for hybrid assembly annotation.\n\n"

# Run Prokka to create annotation
prokka "$HYBRID_ASMBLY" \
--outdir "$OUTDIR_HYBRID" --force \
--prefix "${SAMPLE}_hybrid_annotated" \
--kingdom Archaea \
--genus Haloferax \
--species volcanii \
--strain DS2 \
--usegenus

# Completing Prokka
printf "\n$(date): Completed Prokka for hybrid assembly annotation.\n\n"




# deactivate conda environment
conda deactivate 
