#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=15g
#SBATCH --time=01:00:00
#SBATCH --job-name=03a_BLASTN_subset
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 21.04.2026
## Description: Script to produce a FASTA subset of FASTQ R1 (forward) short reads to be used in a BLASTN search to identify sample origin.
## Usage: Execute from script directory

## Software used:
#  Seqtk = (purpose) take a pseudo-random sample of genomic data for an accurate BLASTN search

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
SCRIPT=${PROJECT_ROOT}/scripts/03_sample_id/03a_BLASTN_subset.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_assembly

# Load samples into an array for parallel processing
mapfile -t SAMPLES < "${PROJECT_ROOT}/sample_list.txt"

# Get the current sample based on SLURM_ARRAY_TASK_ID
# Task ID '0' = Sample 1
# Task ID '1' = Sample 4
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

# Define output directory
OUTDIR="${PROJECT_ROOT}/data/processed/${SAMPLE}/subset"

# Create output directory
printf "\n$(date): Creating subset output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR"
printf "\n$(date): Creating subset output directory for ${SAMPLE} in in $SLURM_JOB_NAME: Finished.\n\n"

# Define input files (raw short reads)
READS_SHORT="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R1.fastq.gz"


## Subset FASTQ data
# Subset = 1000 reads
# Random seed = 100
seqtk sample -s100 "$READS_SHORT" 1000 > "$OUTDIR/${SAMPLE}_R1_subset_1000.fastq"

# Convert FASTQ to FASTA for BLASTN search compatibility
seqtk seq -a "$OUTDIR/${SAMPLE}_R1_subset_1000.fastq" > "$OUTDIR/${SAMPLE}_R1_subset_1000.fasta"


# deactivate conda environment
conda deactivate 
