#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=25g
#SBATCH --time=01:00:00
#SBATCH --job-name=03b_retrieve_reference_genome
#SBATCH --output=../../logs/slurm-%x-%j.out

##########################

## Author: Chris Janschke
## Date: 21.04.2026
## Description: Download reference genome and annotation files from NCBI then index reference genome.
## Usage: Execute from script directory

## Software used:
#  BWA = (purpose) index reference genome
#  Samtools = (purpose) index reference genome

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
SCRIPT=${PROJECT_ROOT}/scripts/03_sample_id/03b_retrieve_reference_genome.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile

# Activate conda environment
conda activate L4136_R1_G4_assembly

# Define annotation eference data directory
ANNOTATION_DIR="${PROJECT_ROOT}/data/reference/genome_annotation"

# Create output directory
mkdir -p "$ANNOTATION_DIR"

# Navigate to reference genome annotation directory
cd "${ANNOTATION_DIR}"

# Download annotation files
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/025/685/GCF_000025685.1_ASM2568v1/GCF_000025685.1_ASM2568v1_genomic.gff.gz 
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/025/685/GCF_000025685.1_ASM2568v1/GCF_000025685.1_ASM2568v1_genomic.gbff.gz 

# Define assembly reference data directory
ASSEMBLY_DIR="${PROJECT_ROOT}/data/reference/genome_assembly"

# Create output directory
mkdir -p "$ASSEMBLY_DIR"

# Navigate to reference genome annotation directory
cd "${ASSEMBLY_DIR}"

# Download assembly file
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/025/685/GCF_000025685.1_ASM2568v1/GCF_000025685.1_ASM2568v1_genomic.fna.gz 

# Unzip reference assembly FASTA for compatability with indexing software
gunzip -k GCF_000025685.1_ASM2568v1_genomic.fna.gz

# Index reference genome assembly
bwa index "GCF_000025685.1_ASM2568v1_genomic.fna"
samtools faidx "GCF_000025685.1_ASM2568v1_genomic.fna"

# deactivate conda environment
conda deactivate 

