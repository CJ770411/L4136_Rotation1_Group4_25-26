#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2 # One task per sample
#SBATCH --cpus-per-task=8
#SBATCH --mem=16g
#SBATCH --time=01:00:00
#SBATCH --job-name=02a_shortread_qc
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 21.04.2026
## Description: Script to perform QC on short read Illumina data.
## Usage: Execute from script directory

## Software used:
#  fastqc

##########################

# Set error handling
# PARAMETERS:
# -e Exit immediately
# -o pipefail Fail pipeline
set -e -o pipefail

# Define project root for downstream navigation
PROJECT_ROOT="$(realpath "${SLURM_SUBMIT_DIR}/../..")" # 2nd Parent directory of script

# Confirm script has been called from the script directory
# and if it hasn't, abandon script execution
SCRIPT=${PROJECT_ROOT}/scripts/02_reads_qc/02a_shortread_qc.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_quality_control

# Load samples into an array
mapfile -t SAMPLES < "${PROJECT_ROOT}/sample_list.txt"

# Get the current sample based on SLURM_ARRAY_TASK_ID
# Task ID '0' = Sample 1
# Task ID '1' = Sample 4
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

# Define output directory 
OUTDIR="${PROJECT_ROOT}/results/${SAMPLE}/reads_qc/shortread"

# Create output directory
echo "Creating short read output directory"
mkdir -p "$OUTDIR"
echo "Creating short read output directory: Finished"

# Define input files (S = shortread, R1 = forward, R2 = reverse)
R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R1.fastq.gz"
R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R2.fastq.gz"

## Run FastQC on merged forward and reverse short read Illumina data
fastqc \
$R1 \
$R2 \
-o "$OUTDIR" \
-t $SLURM_CPUS_PER_TASK

# deactivate conda environment
conda deactivate 
