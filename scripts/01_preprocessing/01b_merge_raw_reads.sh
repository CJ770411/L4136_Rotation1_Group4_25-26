#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1 
#SBATCH --cpus-per-task=1
#SBATCH --mem=2g
#SBATCH --time=00:30:00
#SBATCH --job-name=01b_merge_raw_reads
#SBATCH --output=../../logs/slurm-%x-%j.out


### Script to merge multiple files of raw short read (Illumina) 
### and long read (Nanopore) sequencing data and save the output 
### in the correct file location and with the correct designation
### for downstream processing

# Execute from script directory

## ARGUMENTS
# ARG1 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R1
# ARG2 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R2
# ARG3 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, pass data
# ARG4 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, fail data
# ARG5 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R1
# ARG6 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R2
# ARG7 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, pass data
# ARG8 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, fail data

# Use wildcards to pass multiple of the same file type in each argument.
# Ensure absolute paths are in quotes if it contains a wildcard e.g.
# "/abs/path/to/file/H3932_S4_L00*_R1_001.fastq.gz"


# This script is suitable and required for singular files in any argument as it is still 
# necessary for these files to be re-named according to the conventions
# defined within this script to allow downstream processing

# Example usage:
# $0 <S1_SR_R1> <S1_SR_R2> <S1_LR_PASS> <S1_LR_FAIL> <S4_SR_R1> <S4_SR_R2> <S4_LR_PASS> <S4_LR_FAIL>  


## Set error handling 

# Exit script upon error
# PARAMETERS:
# -e Exit immediately
# -o pipefail Fail pipeline
set -e -o pipefail

# Error triggered if number of arguments received is incorrect 
if [ "$#" -ne 8 ]; then
	printf "Error: Number of given arguments does not match number of required arguments \n"
	printf "%s\tUsage: $0 <S1_SR_R1> <S1_SR_R2> <S1_LR_PASS> <S1_LR_FAIL> <S4_SR_R1> <S4_SR_R2> <S4_LR_PASS> <S4_LR_FAIL>\n"
	printf "\tSee script contents and README for more details\n\n"
	exit 1
fi

# Error triggered if file(s) provided are not .fastq.gz
for file in "$@"; do
	if [[ "$file" != *.fastq.gz ]]; then
		echo "Error: the following file is not .fastq.gz: $file"
		exit 1
	fi
done


# Define project root for downstream navigation
PROJECT_ROOT="$(realpath "${SLURM_SUBMIT_DIR}/../..")" # 2nd Parent directory of script

# Confirm script has been called from the script directory
# and if it hasn't, abandon script execution
SCRIPT=${PROJECT_ROOT}/scripts/01_preprocessing/01b_merge_raw_reads.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Display script start time
printf "\nScript started: $(date)\n\n"

# Display arguments passed
printf "Arguments passed: \n\n"
printf "%s\n\n" "$@"


### Sample 1

## Short reads
# Merge lane 1-4 of short read Illumina FASTQ data 
# All lanes are merged to reduce risk of lane-specific anomalies

# Define output directory (SR = short read, S1 = sample 1)
OUTDIR_SR_S1="${PROJECT_ROOT}/data/processed/sample1/merged_fastq/shortread"

# Initiating output directory creation
printf "Creating merged short reads output directory for Sample 1\n\n"

# Creating output directory
mkdir -p "$OUTDIR_SR_S1"

# Confirming completion
printf "Output directory created: %s\n\n" "${OUTDIR_SR_S1}"
printf "Creating merged short reads output directory for Sample 1: Finished\n\n"

# Define input files 
SR_S1_R1="$1" # Sample 1, Short reads, R1
SR_S1_R2="$2" # Sample 1, Short reads, R2

# Initiating short read merging for Sample 1
printf "Merging short reads for Sample 1\n\n"
printf "Files to be merged R1: %s\n\n" "$SR_S1_R1" 
printf "Files to be merged R2: %s\n\n" "$SR_S1_R2" 

# Merge shortread FASTQ files for Sample 1
cat $SR_S1_R1 > "${OUTDIR_SR_S1}/sample1_merged_shortread_R1.fastq.gz" # R1
cat $SR_S1_R2 > "${OUTDIR_SR_S1}/sample1_merged_shortread_R2.fastq.gz" # R2

# Confirming completion
printf "Merged short reads R1: %s\n\n" "${OUTDIR_SR_S1}/sample1_merged_shortread_R1.fastq.gz"
printf "Merged short reads R2: %s\n\n" "${OUTDIR_SR_S1}/sample1_merged_shortread_R2.fastq.gz"
printf "Merging short reads for Sample 1: Finished\n\n"



## Long reads 
# Merge long read Nanopore FASTQ data
# Nanopore 'pass' and 'fail' data are merged to prevent data loss

# Define output directory (LR = long read, S1 = sample 1)
OUTDIR_LR_S1="${PROJECT_ROOT}/data/processed/sample1/merged_fastq/longread"

# Initiating output directory creation
printf "Creating merged long reads output directory for Sample 1\n\n"

# Creating output directory
mkdir -p "$OUTDIR_LR_S1"

# Confirming completion
printf "Output directory created: %s\n\n" "${OUTDIR_LR_S1}"
printf "Creating merged long reads output directory for Sample 1: Finished\n\n"

# Define input files 
LR_S1_PASS="$3" # Sample 1, Long reads, Pass data
LR_S1_FAIL="$4" # Sample 1, Long reads, Fail data

# Initiating long read merging for Sample 1
printf "Merging long reads for Sample 1\n\n"
printf "Files to be merged (PASS): %s\n\n" "$3" 
printf "Files to be merged (FAIL): %s\n\n" "$4" 

# Merge longread FASTQ files for Sample 1
cat $LR_S1_PASS $LR_S1_FAIL > "${OUTDIR_LR_S1}/sample1_merged_longread.fastq.gz" 

# Confirming completion
printf "Merged long reads: %s\n\n" "${OUTDIR_LR_S1}/sample1_merged_longread.fastq.gz"
printf "Merging long reads for Sample 1: Finished\n\n"



### Sample 4

## Short reads
# Merge lane 1-4 of short read Illumina FASTQ data 
# All lanes are merged to reduce risk of lane-specific anomalies

# Define output directory (SR = short read, S4 = sample 4)
OUTDIR_SR_S4="${PROJECT_ROOT}/data/processed/sample4/merged_fastq/shortread"

# Initiating output directory creation
printf "Creating merged short reads output directory for Sample 4\n\n"

# Creating output directory
mkdir -p "$OUTDIR_SR_S4"

# Confirming completion
printf "Output directory created: %s\n\n" "${OUTDIR_SR_S4}"
printf "Creating merged short reads output directory for Sample 4: Finished\n\n"

# Define input files 
SR_S4_R1="$5" # Sample 4, Short reads, R1
SR_S4_R2="$6" # Sample 4, Short reads, R2

# Initiating short read merging for Sample 4
printf "Merging short reads for Sample 4\n\n"
printf "Files to be merged R1: %s\n\n" "$5" 
printf "Files to be merged R2: %s\n\n" "$6" 

# Merge shortread FASTQ files for Sample 4
cat $SR_S4_R1 > "${OUTDIR_SR_S4}/sample4_merged_shortread_R1.fastq.gz" # R1
cat $SR_S4_R2 > "${OUTDIR_SR_S4}/sample4_merged_shortread_R2.fastq.gz" # R2

# Confirming completion
printf "Merged short reads R1: %s\n\n" "${OUTDIR_SR_S4}/sample4_merged_shortread_R1.fastq.gz"
printf "Merged short reads R2: %s\n\n" "${OUTDIR_SR_S4}/sample4_merged_shortread_R2.fastq.gz"
printf "Merging short reads for Sample 4: Finished\n\n"



## Long reads 
# Merge long read Nanopore FASTQ data
# Nanopore 'pass' and 'fail' data are merged to prevent data loss

# Define output directory (LR = long read, S4 = sample 4)
OUTDIR_LR_S4="${PROJECT_ROOT}/data/processed/sample4/merged_fastq/longread"

# Initiating output directory creation
printf "Creating merged long reads output directory for Sample 4\n\n"

# Creating output directory
mkdir -p "$OUTDIR_LR_S4"

# Confirming completion
printf "Output directory created: %s\n\n" "${OUTDIR_LR_S4}"
printf "Creating merged long reads output directory for Sample 4: Finished\n\n"

# Define input files 
LR_S4_PASS="$7" # Sample 4, Long reads, Pass data
LR_S4_FAIL="$8" # Sample 4, Long reads, Fail data

# Initiating long read merging for Sample 4
printf "Merging long reads for Sample 4\n\n"
printf "Files to be merged (PASS): %s\n\n" "$7" 
printf "Files to be merged (FAIL): %s\n\n" "$8" 

# Merge longread FASTQ files for Sample 4
cat $LR_S4_PASS $LR_S4_FAIL > "${OUTDIR_LR_S4}/sample4_merged_longread.fastq.gz" 

# Confirming completion
printf "Merged long reads: %s\n\n" "${OUTDIR_LR_S4}/sample4_merged_longread.fastq.gz"
printf "Merging long reads for Sample 4: Finished\n\n"

# Display script completion time
printf "Script completed: $(date)\n\n"

