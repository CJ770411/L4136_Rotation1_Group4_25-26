#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=150g
#SBATCH --time=24:00:00
#SBATCH --job-name=04_de_novo_assembly
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 21.04.2026
## Description: Script to produce de novo short read (Illumina), long read (Nanopore) and hybrid genome assemblies.
## Usage: Execute from script directory

## Software used:
#  unicycler = (purpose) de novo genome assembly

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
SCRIPT=${PROJECT_ROOT}/scripts/04_assembly/04_de_novo_assembly.sh
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

### SHORTREAD ASSEMBLY

# Define output directory 
OUTDIR_SHORT="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/shortread"

# Create output directory
printf "\n$(date): Creating short read output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_SHORT"
printf "\n$(date): Creating short read output directory for ${SAMPLE} in in $SLURM_JOB_NAME: Finished.\n\n"


# Define input files (R1 = raw forward reads, R2 = raw reverse reads)
READS_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R1.fastq.gz"
READS_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R2.fastq.gz"

# Run unicycler on merged R1 and R2 short read FASTQ files to create assembly
echo "Starting short read assembly: $(date)"

# Default output FASTA is "assembly.fasta"
unicycler \
-1 "$READS_R1" \
-2 "$READS_R2" \
-o "$OUTDIR_SHORT" \
--threads $SLURM_CPUS_PER_TASK

# Re-name default output FASTA to "shortread_assembly.fasta"
mv "$OUTDIR_SHORT"/assembly.fasta "$OUTDIR_SHORT"/${SAMPLE}_shortread_assembly.fasta

echo "Finished short read assembly: $(date)"



### LONGREAD ASSEMBLY

# Define output directory 
OUTDIR_LONG="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/longread"

# Create output directory
printf "\n$(date): Creating long read output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_LONG"
printf "\n$(date): Creating long read output directory for ${SAMPLE} in in $SLURM_JOB_NAME: Finished.\n\n"


# Define input file (raw long reads)
READS_LONG="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/longread/${SAMPLE}_merged_longread.fastq.gz"

# Run unicycler on merged long read FASTQ files to create assembly
echo "Starting long read assembly: $(date)"

# Default output FASTA is "assembly.fasta"
unicycler \
-l "$READS_LONG" \
-o "$OUTDIR_LONG" \
--threads $SLURM_CPUS_PER_TASK

# Re-name default output FASTA to "longread_assembly.fasta"
mv "$OUTDIR_LONG"/assembly.fasta "$OUTDIR_LONG"/${SAMPLE}_longread_assembly.fasta

echo "Finished long read assembly: $(date)"




### HYBRID ASSEMBLY

# Define output directory 
OUTDIR_HYBRID="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/hybrid"

# Create output directory
printf "\n$(date): Creating hybrid output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_HYBRID"
printf "\n$(date): Creating hybrid output directory for ${SAMPLE} in in $SLURM_JOB_NAME: Finished.\n\n"

# Run unicycler on merged hybrid read FASTQ files to create assembly
echo "Starting hybrid read assembly: $(date)"

# Short and long read input FASTQ files defined above.
# Default output FASTA is "assembly.fasta"
unicycler \
-1 "$READS_R1" \
-2 "$READS_R2"  \
-l "$READS_LONG" \
-o "$OUTDIR_HYBRID" \
--threads $SLURM_CPUS_PER_TASK

# Re-name default output FASTA to "hybrid_assembly.fasta"
mv "$OUTDIR_HYBRID"/assembly.fasta "$OUTDIR_HYBRID"/${SAMPLE}_hybrid_assembly.fasta

echo "Finished hybrid read assembly: $(date)"



# deactivate conda environment
conda deactivate 
