#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100g
#SBATCH --time=12:00:00
#SBATCH --job-name=05a_polish_shortread
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 21.04.2026
## Description: Script to polish de novo short read (Illumina) genome assemblies with raw short reads. 
##				Polishing is repeated for two rounds to improve results.
##				PCR duplicates are removed from short reads prior to polishing.
## Usage: Execute from script directory

## Software used:
#  Picard = (purpose) remove PCR duplicates
#  BWA = (purpose) index assemblies and perform alignment
#  Samtools = (purpose) index assemblies and create BAM alignment file
#  Pilon = (purpose) polish using short read data

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
SCRIPT=${PROJECT_ROOT}/scripts/05_polishing/05a_polish_shortread.sh
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

# Define input files containing raw short reads used for polishing each assembly 
# (R1 = raw forward reads, R2 = raw reverse reads)
READS_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R1.fastq.gz"
READS_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R2.fastq.gz"



### Polishing - ROUND 1

# Initiating polishing round 1 
printf "\n$(date): Starting ROUND 1 polishing short read assembly\n\n"

# Define output directory 
OUTDIR_ROUND_1="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_1"

# Create output directory
printf "\n$(date): Creating ROUND 1 short read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_ROUND_1"
printf "\n$(date): Creating ROUND 1 short read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (raw assembly to be polished)
RAW_ASSEMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/shortread/${SAMPLE}_shortread_assembly.fasta"

# Index raw assembly 
bwa index "$RAW_ASSEMBLY" 
samtools faidx "$RAW_ASSEMBLY"

# Align short reads to raw short read assembly
bwa mem -M -t $SLURM_CPUS_PER_TASK "$RAW_ASSEMBLY" \
"$READS_R1" "$READS_R2" \
| samtools view -b \
| samtools sort -o "$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.sort.bam"

# Remove PCR duplicates from round 1 BAM 
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT="$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.sort.bam" \
OUTPUT="$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.rmd.bam" \
METRICS_FILE="$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.rmd.bam.metrics" 

# Index BAM file 
samtools index "$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.rmd.bam"

# Remove .sort.bam to clean up
rm "$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.sort.bam"

# Run Pilon to polish the raw assembly
# Default output assembly FASTA is "pilon.fasta"
# Execute Pilon either by calling the software or by sourcing the .jar file
#java -Xmx100G -jar <path_to_pilon.jar> \
pilon \
--genome "$RAW_ASSEMBLY" \
--bam "$OUTDIR_ROUND_1/${SAMPLE}_shortread_round_1.rmd.bam" \
--outdir "$OUTDIR_ROUND_1" 

# Re-name default output FASTA to "shortread_assembly_polished_round_1.fasta"
mv "$OUTDIR_ROUND_1/pilon.fasta" "$OUTDIR_ROUND_1/${SAMPLE}_shortread_polished_round_1.fasta" 

# Completing polishing round 1 
printf "\n$(date): Finished ROUND 1 polishing short read assembly\n\n"



### Polishing - ROUND 2

# Initiating polishing round 2
printf "\n$(date): Starting ROUND 2 polishing short read assembly\n\n"

# Define output directory 
OUTDIR_ROUND_2="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/shortread/round_2"

# Create output directory
printf "\n$(date): Creating ROUND 2 short read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_ROUND_2"
printf "\n$(date): Creating ROUND 2 short read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (raw assembly to be polished)
ROUND_1_ASSEMBLY="$OUTDIR_ROUND_1/${SAMPLE}_shortread_polished_round_1.fasta"

# Index round 1 polished assembly 
bwa index "$ROUND_1_ASSEMBLY" 
samtools faidx "$ROUND_1_ASSEMBLY"

# Align short reads to raw short read assembly
bwa mem -M -t $SLURM_CPUS_PER_TASK "$ROUND_1_ASSEMBLY" \
"$READS_R1" "$READS_R2" \
| samtools view -b \
| samtools sort -o "$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.sort.bam"

# Remove PCR duplicates from round 2 BAM 
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT="$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.sort.bam" \
OUTPUT="$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.rmd.bam" \
METRICS_FILE="$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.rmd.bam.metrics" 

# Index BAM file 
samtools index "$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.rmd.bam"

# Remove .sort.bam to clean up
rm "$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.sort.bam"

# Run Pilon to polish the round 1 assembly
# Default output assembly FASTA is "pilon.fasta"
# Execute Pilon either by calling the software or by sourcing the .jar file
#java -Xmx100G -jar <path_to_pilon.jar> \
pilon \
--genome "$ROUND_1_ASSEMBLY" \
--bam "$OUTDIR_ROUND_2/${SAMPLE}_shortread_round_2.rmd.bam" \
--outdir "$OUTDIR_ROUND_2" 

# Re-name default output FASTA to "shortread_assembly_polished_round_2.fasta"
mv "$OUTDIR_ROUND_2/pilon.fasta" "$OUTDIR_ROUND_2/${SAMPLE}_shortread_polished_round_2.fasta"

# Index final polished assembly
bwa index "$OUTDIR_ROUND_2/${SAMPLE}_shortread_polished_round_2.fasta" 
samtools faidx "$OUTDIR_ROUND_2/${SAMPLE}_shortread_polished_round_2.fasta"

# Completing polishing round 2 
printf "\n$(date): Finished ROUND 2 polishing short read assembly\n\n"

# deactivate conda environment
conda deactivate 
