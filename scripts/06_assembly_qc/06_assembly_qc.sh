#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=150g
#SBATCH --time=12:00:00
#SBATCH --job-name=06_assembly_qc
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 22.04.2026
## Description: Script to produce a quality control (QC) report for:
##              1. Raw vs polished short read, long read and hybrid genome assemblies. 
##              2. Comparison of short read genome assemblies: raw, round 1 polished, round 2 polished.
##              3. Comparison of long read genome assemblies: raw, round 1 polished, round 2 polished, round 3 polished, round 4 polished.
##              4. Comparison of hybrid genome assemblies: raw, round 1 polished, round 2 polished, round 3 polished, round 4 polished.
## Usage: Execute from script directory

## Software used:
#  Quast = (purpose) de novo genome assembly QC

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
SCRIPT=${PROJECT_ROOT}/scripts/06_assembly_qc/06_assembly_qc.sh
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

# Define raw FASTQ read data (S = shortread, R1 = forward, R2 = reverse, L = longread)
SHORT_READS_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R1.fastq.gz"
SHORT_READS_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R2.fastq.gz"
LONG_READS="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/longread/${SAMPLE}_merged_longread.fastq.gz"

# Define Haloferax reference assembly and annotation
# Assembly
REF_ASS="${PROJECT_ROOT}/data/reference/genome_assembly/GCF_000025685.1_ASM2568v1_genomic.fna.gz"
# Annotation
REF_ANN="${PROJECT_ROOT}/data/reference/genome_annotation/GCF_000025685.1_ASM2568v1_genomic.gff.gz"


# 1. Raw vs Polished

# Define output directory 
OUTDIR_RAW_V_POL="${PROJECT_ROOT}/results/${SAMPLE}/assembly/qc/raw_vs_polished"

# Create output directory
printf "\n$(date): Creating raw vs polished assembly QC output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_RAW_V_POL"
printf "\n$(date): Creating raw vs polished assembly QC output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input files (raw and polished assemblies)
# Raw assemblies
SHORT_ASMBLY_RAW="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/shortread/${SAMPLE}_shortread_assembly.fasta"
LONG_ASMBLY_RAW="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/longread/${SAMPLE}_longread_assembly.fasta"
HYBRID_ASMBLY_RAW="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/hybrid/${SAMPLE}_hybrid_assembly.fasta"

# Polished assemblies
SHORT_ASMBLY_POL="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_2/${SAMPLE}_shortread_polished_round_2.fasta"
LONG_ASMBLY_POL="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_4/${SAMPLE}_longread_polished_round_4.fasta"
HYBRID_ASMBLY_POL="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_4/${SAMPLE}_hybrid_polished_round_4.fasta"

# Initiating Quast
printf "\n$(date): Running Quast for Raw vs Polished QC report.\n\n"

# Run Quast to produce QC report
quast \
"$SHORT_ASMBLY_RAW" \
"$LONG_ASMBLY_RAW" \
"$HYBRID_ASMBLY_RAW" \
"$SHORT_ASMBLY_POL" \
"$LONG_ASMBLY_POL" \
"$HYBRID_ASMBLY_POL" \
-r "$REF_ASS" \
-g "$REF_ANN" \
-1 "$SHORT_READS_R1" \
-2 "$SHORT_READS_R2" \
--nanopore "$LONG_READS" \
-o "$OUTDIR_RAW_V_POL"

# Completing Quast
printf "\n$(date): Completed Quast for Raw vs Polished QC report.\n\n"



# 2. Short read polishing rounds

# Define output directory 
OUTDIR_SHORT_ROUNDS="${PROJECT_ROOT}/results/${SAMPLE}/assembly/qc/polishing_rounds/shortread"

# Create output directory
printf "\n$(date): Creating output directory for short read assembly QC rounds for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_SHORT_ROUNDS"
printf "\n$(date): Creating output directory for short read assembly QC rounds for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"


# Define input files (raw assembly and assembly from each round of polishing)
SHORT_ASMBLY_RAW="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/shortread/${SAMPLE}_shortread_assembly.fasta" # Raw assembly
SHORT_ASMBLY_POL_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_1/${SAMPLE}_shortread_polished_round_1.fasta" # Polished round 1
SHORT_ASMBLY_POL_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_2/${SAMPLE}_shortread_polished_round_2.fasta" # Polished round 2

# Initiating Quast
printf "\n$(date): Running Quast for Short Read Rounds QC report.\n\n"

# Run Quast to produce QC report
quast \
"$SHORT_ASMBLY_RAW" \
"$SHORT_ASMBLY_POL_R1" \
"$SHORT_ASMBLY_POL_R2" \
-r "$REF_ASS" \
-g "$REF_ANN" \
-1 "$SHORT_READS_R1" \
-2 "$SHORT_READS_R2" \
-o "$OUTDIR_SHORT_ROUNDS"

# Completing Quast
printf "\n$(date): Completed Quast for Short Read Rounds QC report.\n\n"



# 3. Long read polishing rounds

# Define output directory 
OUTDIR_LONG_ROUNDS="${PROJECT_ROOT}/results/${SAMPLE}/assembly/qc/polishing_rounds/longread"

# Create output directory
printf "\n$(date): Creating output directory for long read assembly QC rounds for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_LONG_ROUNDS"
printf "\n$(date): Creating output directory for long read assembly QC rounds for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"


# Define input files (raw assembly and assembly from each round of polishing)
LONG_ASMBLY_RAW="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/longread/${SAMPLE}_longread_assembly.fasta" # Raw assembly
LONG_ASMBLY_POL_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_1/${SAMPLE}_longread_polished_round_1.fasta" # Polished round 1
LONG_ASMBLY_POL_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_2/${SAMPLE}_longread_polished_round_2.fasta" # Polished round 2
LONG_ASMBLY_POL_R3="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_3/${SAMPLE}_longread_polished_round_3.fasta" # Polished round 3
LONG_ASMBLY_POL_R4="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_4/${SAMPLE}_longread_polished_round_4.fasta" # Polished round 4


# Initiating Quast
printf "\n$(date): Running Quast for Long Read Rounds QC report.\n\n"

# Run Quast to produce QC report
quast \
"$LONG_ASMBLY_RAW" \
"$LONG_ASMBLY_POL_R1" \
"$LONG_ASMBLY_POL_R2" \
"$LONG_ASMBLY_POL_R3" \
"$LONG_ASMBLY_POL_R4" \
-r "$REF_ASS" \
-g "$REF_ANN" \
--nanopore "$LONG_READS" \
-o "$OUTDIR_LONG_ROUNDS"

# Completing Quast
printf "\n$(date): Completed Quast for Long Read Rounds QC report.\n\n"




# 4. Hybrid polishing rounds

# Define output directory 
OUTDIR_HYBRID_ROUNDS="${PROJECT_ROOT}/results/${SAMPLE}/assembly/qc/polishing_rounds/hybrid"

# Create output directory
printf "\n$(date): Creating output directory for hybrid assembly QC rounds for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_HYBRID_ROUNDS"
printf "\n$(date): Creating output directory for hybrid assembly QC rounds for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"


# Define input files (raw assembly and assembly from each round of polishing)
HYBRID_ASMBLY_RAW="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/hybrid/${SAMPLE}_hybrid_assembly.fasta" # Raw assembly
HYBRID_ASMBLY_POL_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_1/${SAMPLE}_hybrid_polished_round_1.fasta" # Polished round 1
HYBRID_ASMBLY_POL_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_2/${SAMPLE}_hybrid_polished_round_2.fasta" # Polished round 2
HYBRID_ASMBLY_POL_R3="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_3/${SAMPLE}_hybrid_polished_round_3.fasta" # Polished round 3
HYBRID_ASMBLY_POL_R4="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/hybrid/round_4/${SAMPLE}_hybrid_polished_round_4.fasta" # Polished round 4


# Initiating Quast
printf "\n$(date): Running Quast for Hybrid Rounds QC report.\n\n"

# Run Quast to produce QC report
quast \
"$HYBRID_ASMBLY_RAW" \
"$HYBRID_ASMBLY_POL_R1" \
"$HYBRID_ASMBLY_POL_R2" \
"$HYBRID_ASMBLY_POL_R3" \
"$HYBRID_ASMBLY_POL_R4" \
-r "$REF_ASS" \
-g "$REF_ANN" \
-1 "$SHORT_READS_R1" \
-2 "$SHORT_READS_R2" \
--nanopore "$LONG_READS" \
-o "$OUTDIR_HYBRID_ROUNDS"

# Completing Quast
printf "\n$(date): Completed Quast for Hybrid Rounds QC report.\n\n"


# deactivate conda environment
conda deactivate 
