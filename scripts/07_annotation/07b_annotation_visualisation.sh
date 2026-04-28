#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50g
#SBATCH --time=02:00:00
#SBATCH --job-name=07b_annotation_visualisation
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 22.04.2026
## Description: Script to perform annotation visualisation of:
#               1. Haloferax volcanii reference assembly
#               2. Short read genome assembly
#               3. Long read genome assembly
#               4. Hybrid genome assembly
## Usage: Execute from script directory

## Software used:
#  GenoVi = (purpose) genome annotation visualisation

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
SCRIPT=${PROJECT_ROOT}/scripts/07_annotation/07b_annotation_visualisation.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_genovi

# Load samples into an array
mapfile -t SAMPLES < "${PROJECT_ROOT}/sample_list.txt"

# Get the current sample based on SLURM_ARRAY_TASK_ID
# Task ID '0' = Sample 1
# Task ID '1' = Sample 4
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}


# 1. Reference assembly annotation visualisation (Haloferax volcanii)

# Define output directory 
OUTDIR_REF="${PROJECT_ROOT}/results/${SAMPLE}/annotation/visualisation/reference"

# Create output directory
printf "\n$(date): Creating reference assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_REF"
printf "\n$(date): Creating reference assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Navigate to output directory 
cd "${OUTDIR_REF}"

# Define input file (reference assembly annotation)
REF_ANNOT="${PROJECT_ROOT}/data/reference/genome_annotation/GCF_000025685.1_ASM2568v1_genomic.gbff.gz"

# Initiating Genovi
printf "\n$(date): Running Genovi for reference assembly annotation.\n\n"

# Run Genovi
genovi \
-i "$REF_ANNOT" \
-s draft \
-cs autumn \
-bc white \
-o reference \
-te \
--size \
-t "Reference Assembly"

# Completing Genovi
printf "\n$(date): Completed Genovi for reference assembly annotation.\n\n"



# 2. Short read assembly annotation visualisation

# Define output directory 
OUTDIR_SHORT="${PROJECT_ROOT}/results/${SAMPLE}/annotation/visualisation/shortread"

# Create output directory
printf "\n$(date): Creating short read assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_SHORT"
printf "\n$(date): Creating short read assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Navigate to output directory 
cd "${OUTDIR_SHORT}"

# Define input file (polished short read assembly annotation)
SHORT_ANNOT="${PROJECT_ROOT}/data/processed/${SAMPLE}/annotated/shortread/${SAMPLE}_shortread_annotated.gbk"

# Initiating Genovi
printf "\n$(date): Running Genovi for short read assembly annotation.\n\n"

# Run Genovi
genovi \
-i "$SHORT_ANNOT" \
-s draft \
-cs autumn \
-bc white \
-o ${SAMPLE}_shortread \
-te \
--size \
-t "Short Read Assembly"

# Completing Genovi
printf "\n$(date): Completed Genovi for short read assembly annotation.\n\n"




# 3. Long read assembly annotation visualisation

# Define output directory 
OUTDIR_LONG="${PROJECT_ROOT}/results/${SAMPLE}/annotation/visualisation/longread"

# Create output directory
printf "\n$(date): Creating long read assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_LONG"
printf "\n$(date): Creating long read assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Navigate to output directory 
cd "${OUTDIR_LONG}"

# Define input file (polished long read assembly annotation)
LONG_ANNOT="${PROJECT_ROOT}/data/processed/${SAMPLE}/annotated/longread/${SAMPLE}_longread_annotated.gbk"

# Initiating Genovi
printf "\n$(date): Running Genovi for long read assembly annotation.\n\n"

# Run Genovi
genovi \
-i "$LONG_ANNOT" \
-s draft \
-cs autumn \
-bc white \
-o ${SAMPLE}_longread \
-te \
--size \
-t "Long Read Assembly"

# Completing Genovi
printf "\n$(date): Completed Genovi for long read assembly annotation.\n\n"




# 4. Hybrid assembly annotation visualisation

# Define output directory 
OUTDIR_HYBRID="${PROJECT_ROOT}/results/${SAMPLE}/annotation/visualisation/hybrid"

# Create output directory
printf "\n$(date): Creating hybrid assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_HYBRID"
printf "\n$(date): Creating hybrid assembly annotation visualisation output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Navigate to output directory 
cd "${OUTDIR_HYBRID}"

# Define input file (polished hybrid assembly annotation)
HYBRID_ANNOT="${PROJECT_ROOT}/data/processed/${SAMPLE}/annotated/hybrid/${SAMPLE}_hybrid_annotated.gbk"

# Initiating Genovi
printf "\n$(date): Running Genovi for hybrid assembly annotation.\n\n"

# Run Genovi
genovi \
-i "$HYBRID_ANNOT" \
-s draft \
-cs autumn \
-bc white \
-o ${SAMPLE}_hybrid \
-te \
--size \
-t "Hybrid Assembly"

# Completing Genovi
printf "\n$(date): Completed Genovi for hybrid assembly annotation.\n\n"



# deactivate conda environment
conda deactivate 
