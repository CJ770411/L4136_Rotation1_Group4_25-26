#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=150g
#SBATCH --time=12:00:00
#SBATCH --job-name=05b_polish_longread
#SBATCH --output=../../logs/slurm-%x-%j.out
#SBATCH --array=0-1 # Two samples

##########################

## Author: Chris Janschke
## Date: 21.04.2026
## Description: Script to polish de novo long read (Nanopore) genome assemblies with raw short and long reads.
##				Polishing is repeated for two rounds each with short and long reads to improve results.
##				PCR duplicates are removed from short reads prior to polishing.
## Usage: Execute from script directory

## Software used:
#  Picard = (purpose) remove PCR duplicates
#  BWA = (purpose) index assemblies and perform short read alignment
#  Minimap2 = (purpose) perform long read alignment
#  Samtools = (purpose) index assemblies and create BAM alignment file
#  Racon = (purpose) polish using long read data
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
SCRIPT=${PROJECT_ROOT}/scripts/05_polishing/05b_polish_longread.sh
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

# Define input files containing raw reads used for polishing each assembly 

# Short reads (R1 = raw forward reads, R2 = raw reverse reads)
READS_SHORT_R1="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R1.fastq.gz"
READS_SHORT_R2="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/shortread/${SAMPLE}_merged_shortread_R2.fastq.gz"

# Long reads
READS_LONG="${PROJECT_ROOT}/data/processed/${SAMPLE}/merged_fastq/longread/${SAMPLE}_merged_longread.fastq.gz"




### Polishing - ROUND 1 (long reads)

# Initiating polishing round 1 
printf "\n$(date): Starting ROUND 1 polishing long read assembly with long reads\n\n"

# Define output directory 
OUTDIR_ROUND_1="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_1"

# Create output directory
printf "\n$(date): Creating ROUND 1 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_ROUND_1"
printf "\n$(date): Creating ROUND 1 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Define input file (raw assembly to be polished)
RAW_ASSEMBLY="${PROJECT_ROOT}/data/processed/${SAMPLE}/assembly/longread/${SAMPLE}_longread_assembly.fasta"

# Define output files
ALIGNED_ROUND_1="$OUTDIR_ROUND_1/${SAMPLE}_longread_round_1.paf" # Long reads aligned to raw assembly
POLISHED_ROUND_1="$OUTDIR_ROUND_1/${SAMPLE}_longread_polished_round_1.fasta" # Round 1 polished assembly

# Use minimap2 to align long reads to raw long read assembly
# Outputs PAF file
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-x map-ont "$RAW_ASSEMBLY" "$READS_LONG" > "$ALIGNED_ROUND_1"

# Run Racon to polish 
racon "$READS_LONG" "$ALIGNED_ROUND_1" "$RAW_ASSEMBLY" > "$POLISHED_ROUND_1"

# Completing polishing round 1 
printf "\n$(date): Finished ROUND 1 polishing long read assembly with long reads\n\n"




### Polishing - ROUND 2 (long reads)

# Initiating polishing round 2
printf "\n$(date): Starting ROUND 2 polishing long read assembly with long reads\n\n"

# Define output directory 
OUTDIR_ROUND_2="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_2"

# Create output directory
printf "\n$(date): Creating ROUND 2 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_ROUND_2"
printf "\n$(date): Creating ROUND 2 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Input file is the round 1 polished assembly: "$POLISHED_ROUND_1"


# Define output files
ALIGNED_ROUND_2="$OUTDIR_ROUND_2/${SAMPLE}_longread_round_2.paf" # Long reads aligned to round 1 polished assembly
POLISHED_ROUND_2="$OUTDIR_ROUND_2/${SAMPLE}_longread_polished_round_2.fasta" # Round 2 polished assembly

# Use minimap2 to align long reads to round 1 polished assembly
# Outputs PAF file
minimap2 \
-t $SLURM_CPUS_PER_TASK \
-x map-ont "$POLISHED_ROUND_1" "$READS_LONG" > "$ALIGNED_ROUND_2"

# Run Racon to polish 
racon "$READS_LONG" "$ALIGNED_ROUND_2" "$POLISHED_ROUND_1" > "$POLISHED_ROUND_2"

# Completing polishing round 2 
printf "\n$(date): Finished ROUND 2 polishing long read assembly with long reads\n\n"




### Polishing - ROUND 3 (short reads)

# Initiating polishing round 3
printf "\n$(date): Starting ROUND 3 polishing long read assembly with short reads\n\n"

# Define output directory 
OUTDIR_ROUND_3="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_3"

# Create output directory
printf "\n$(date): Creating ROUND 3 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_ROUND_3"
printf "\n$(date): Creating ROUND 3 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Input file is the round 2 polished assembly: "$POLISHED_ROUND_2"

# Define output files
ALIGNED_ROUND_3="$OUTDIR_ROUND_3/${SAMPLE}_longread_round_3.rmd.bam" # Short reads aligned to round 2 polished assembly
POLISHED_ROUND_3="$OUTDIR_ROUND_3/${SAMPLE}_longread_polished_round_3.fasta" # Round 3 polished assembly

# Index round 2 assembly 
bwa index "$POLISHED_ROUND_2" 
samtools faidx "$POLISHED_ROUND_2"

# Align short reads to round 2 long read assembly
bwa mem -M -t $SLURM_CPUS_PER_TASK "$POLISHED_ROUND_2" \
"$READS_SHORT_R1" "$READS_SHORT_R2" \
| samtools view -b \
| samtools sort -o "$OUTDIR_ROUND_3/${SAMPLE}_longread_round_3.sort.bam"

# Remove PCR duplicates from round 3 BAM 
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT="$OUTDIR_ROUND_3/${SAMPLE}_longread_round_3.sort.bam" \
OUTPUT="$ALIGNED_ROUND_3" \
METRICS_FILE="$OUTDIR_ROUND_3/${SAMPLE}_longread_round_3.rmd.bam.metrics" 

# Index BAM file 
samtools index "$ALIGNED_ROUND_3"

# Remove .sort.bam to clean up
rm "$OUTDIR_ROUND_3/${SAMPLE}_longread_round_3.sort.bam"

# Run Pilon to polish the round 2 assembly
# Default output assembly FASTA is "pilon.fasta"
# Execute Pilon either by calling the software or by sourcing the .jar file
#java -Xmx100G -jar <path_to_pilon.jar> \
#pilon \
java -Xmx100G -jar /gpfs01/home/mbxcj2/miniconda3/envs/assembly/share/pilon-1.24-0/pilon.jar \
--genome "$POLISHED_ROUND_2" \
--bam "$ALIGNED_ROUND_3" \
--outdir "$OUTDIR_ROUND_3" 

# Re-name default output FASTA to "longread_assembly_polished_round_3.fasta"
mv "$OUTDIR_ROUND_3/pilon.fasta" "$POLISHED_ROUND_3" 

# Completing polishing round 3 
printf "\n$(date): Finished ROUND 3 polishing long read assembly\n\n"




### Polishing - ROUND 4 (short reads)

# Initiating polishing round 4
printf "\n$(date): Starting ROUND 4 polishing long read assembly with short reads\n\n"

# Define output directory 
OUTDIR_ROUND_4="${PROJECT_ROOT}/data/processed/${SAMPLE}/polished/longread/round_4"

# Create output directory
printf "\n$(date): Creating ROUND 4 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME\n\n"
mkdir -p "$OUTDIR_ROUND_4"
printf "\n$(date): Creating ROUND 4 long read polishing output directory for ${SAMPLE} in $SLURM_JOB_NAME: Finished\n\n"

# Input file is the round 3 polished assembly: "$POLISHED_ROUND_3"

# Define output files
ALIGNED_ROUND_4="$OUTDIR_ROUND_4/${SAMPLE}_longread_round_4.rmd.bam" # Short reads aligned to round 3 polished assembly
POLISHED_ROUND_4="$OUTDIR_ROUND_4/${SAMPLE}_longread_polished_round_4.fasta" # Round 4 polished assembly

# Index round 3 assembly 
bwa index "$POLISHED_ROUND_3" 
samtools faidx "$POLISHED_ROUND_3"

# Align short reads to round 3 long read assembly
bwa mem -M -t $SLURM_CPUS_PER_TASK "$POLISHED_ROUND_3" \
"$READS_SHORT_R1" "$READS_SHORT_R2" \
| samtools view -b \
| samtools sort -o "$OUTDIR_ROUND_4/${SAMPLE}_longread_round_4.sort.bam"

# Remove PCR duplicates from round 4 BAM 
picard \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT="$OUTDIR_ROUND_4/${SAMPLE}_longread_round_4.sort.bam" \
OUTPUT="$ALIGNED_ROUND_4" \
METRICS_FILE="$OUTDIR_ROUND_4/${SAMPLE}_longread_round_4.rmd.bam.metrics" 

# Index BAM file 
samtools index "$ALIGNED_ROUND_4"

# Remove .sort.bam to clean up
rm "$OUTDIR_ROUND_4/${SAMPLE}_longread_round_4.sort.bam"

# Run Pilon to polish the round 3 assembly
# Default output assembly FASTA is "pilon.fasta"
# Execute Pilon either by calling the software or by sourcing the .jar file
#java -Xmx100G -jar <path_to_pilon.jar> \
#pilon \
java -Xmx100G -jar /gpfs01/home/mbxcj2/miniconda3/envs/assembly/share/pilon-1.24-0/pilon.jar \
--genome "$POLISHED_ROUND_3" \
--bam "$ALIGNED_ROUND_4" \
--outdir "$OUTDIR_ROUND_4" 

# Re-name default output FASTA to "longread_assembly_polished_round_4.fasta"
mv "$OUTDIR_ROUND_4/pilon.fasta" "$POLISHED_ROUND_4" 

# Index round 4 assembly 
bwa index "$POLISHED_ROUND_4"  
samtools faidx "$POLISHED_ROUND_4" 

# Completing polishing round 4 
printf "\n$(date): Finished ROUND 4 polishing long read assembly\n\n"




# deactivate conda environment
conda deactivate 
