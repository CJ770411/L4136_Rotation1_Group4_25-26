#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20g
#SBATCH --time=48:00:00
#SBATCH --job-name=00_pipeline
#SBATCH --output=../../logs/slurm-%x-%j.out

##########################

## Author: Chris Janschke
## Date: 23.04.2026
## Description: Script to execute the analysis pipeline for Sample 1 and Sample 4:
#               1. Merge reads
#               2. Reads quality control (QC)
#               3. Identify sample origin
#               4. Genome assembly
#               5. Polish genome assemblies
#               6. Genome assembly QC
#               7. Genome assembly annotation
#               8. Genome assembly alignment to reference genome
#               9. Variant analysis
## Usage: 
#	 Execute from script directory
#	 ARGUMENTS
#	 ARG1 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R1
#	 ARG2 = (absolute path) FASTQ, gzipped: Sample 1, Short reads, R2
#	 ARG3 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, pass data
#	 ARG4 = (absolute path) FASTQ, gzipped: Sample 1, Long reads, fail data
#	 ARG5 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R1
#	 ARG6 = (absolute path) FASTQ, gzipped: Sample 4, Short reads, R2
#	 ARG7 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, pass data
#	 ARG8 = (absolute path) FASTQ, gzipped: Sample 4, Long reads, fail data

#	 Use wildcards to pass multiple of the same file type in each argument.
#	 Ensure absolute paths are in quotes if it conains a wildcard e.g. 
#	 "/abs/path/to/file/H3932_S4_L00*_R1_001.fastq.gz"

#	 This script is suitable for singular files in any argument as it is still 
#	 necessary for these files to be re-named according to the conventions 
#	 defined within this script to allow downstream processing

#    Example usage:
#    $0 <S1_SR_R1> <S1_SR_R2> <S1_LR_PASS> <S1_LR_FAIL> <S4_SR_R1> <S4_SR_R2> <S4_LR_PASS> <S4_LR_FAIL>  

## Software used:
#  Software defined in constituent scripts.

##########################


## Set error handling

# PARAMETERS:
# -e = Exit immediately
# -o pipefail = Fail pipeline
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
SCRIPT=${PROJECT_ROOT}/scripts/00_pipeline/00_pipeline.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Source bash profile to enable conda
source $HOME/.bash_profile


### Log Handling

# Define log directory
LOG_DIR="${PROJECT_ROOT}/logs"

# Create log directory
mkdir -p "${LOG_DIR}"

# Define log file
LOG_ID=1 # Unique identifier
LOG="${PROJECT_ROOT}/logs/00_pipeline_log_${LOG_ID}.txt"

# Set unique log file name
# Loop to increase unique log ID identifier by 1 until unique name found
while [[ -f "$LOG" ]]; do
	LOG_ID=$((LOG_ID + 1)) # Increase identifier by 1
	LOG="${PROJECT_ROOT}/logs/00_pipeline_log_${LOG_ID}.txt" # Save log file with unique identifier
done 


### Execute Pipeline

## 1. Merge reads


# 01a_create_sample_list.sh

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/01_preprocessing"

# Execute script
JOB_01a=$(sbatch --parsable 01a_create_sample_list.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_01a --wrap \
"echo \"\$(date): Completed script: 01a_create_sample_list.sh\" >> '$LOG'"


# 01b_merge_raw_reads.sh

# Execute script
JOB_01b=$(sbatch --parsable --dependency=afterok:$JOB_01a 01b_merge_raw_reads.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8")

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_01b --wrap \
"echo \"\$(date): Completed script: 01b_merge_raw_reads.sh\" >> '$LOG'"



## 2. Reads quality control (QC)


# 02a_shortread_qc

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/02_reads_qc"

# Execute script
JOB_02a=$(sbatch --parsable --dependency=afterok:$JOB_01b 02a_shortread_qc.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_02a --wrap \
"echo \"\$(date): Completed script: 02a_shortread_qc.sh\" >> '$LOG'"


# 02b_longread_qc

# Execute script
JOB_02b=$(sbatch --parsable --dependency=afterok:$JOB_02a 02b_longread_qc.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_02b --wrap \
"echo \"\$(date): Completed script: 02b_longread_qc.sh\" >> '$LOG'"




## 3. Genome assembly


# 03a_BLASTN_subset

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/03_sample_id"

# Execute script
JOB_03a=$(sbatch --parsable --dependency=afterok:$JOB_02b 03a_BLASTN_subset.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_03a --wrap \
"echo \"\$(date): Completed script: 03a_BLASTN_subset.sh\" >> '$LOG'"


# 03b_retrieve_reference_genome

# Execute script
JOB_03b=$(sbatch --parsable --dependency=afterok:$JOB_03a 03b_retrieve_reference_genome.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_03b --wrap \
"echo \"\$(date): Completed script: 03b_retrieve_reference_genome.sh\" >> '$LOG'"




## 4. Genome assembly


# 04_de_novo_assembly

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/04_assembly"

# Execute script
JOB_04=$(sbatch --parsable --dependency=afterok:$JOB_03b 04_de_novo_assembly.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_04 --wrap \
"echo \"\$(date): Completed script: 04_de_novo_assembly.sh\" >> '$LOG'"




## 5. Polish genome assemblies


# 05a_polish_shortread

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/05_polishing"

# Execute script
JOB_05a=$(sbatch --parsable --dependency=afterok:$JOB_04 05a_polish_shortread.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_05a --wrap \
"echo \"\$(date): Completed script: 05a_polish_shortread.sh\" >> '$LOG'"


# 05b_polish_longread

# Execute script
JOB_05b=$(sbatch --parsable --dependency=afterok:$JOB_05a 05b_polish_longread.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_05b --wrap \
"echo \"\$(date): Completed script: 05b_polish_longread.sh\" >> '$LOG'"


# 05c_polish_hybrid

# Execute script
JOB_05c=$(sbatch --parsable --dependency=afterok:$JOB_05b 05c_polish_hybrid.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_05c --wrap \
"echo \"\$(date): Completed script: 05c_polish_hybrid.sh\" >> '$LOG'"




## 6. Genome assembly QC


# 06_assembly_qc

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/06_assembly_qc"

# Execute script
JOB_06=$(sbatch --parsable --dependency=afterok:$JOB_05c 06_assembly_qc.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_06 --wrap \
"echo \"\$(date): Completed script: 06_assembly_qc.sh\" >> '$LOG'"



## 7. Genome assembly annotation


# 07a_annotation

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/07_annotation"

# Execute script
JOB_07a=$(sbatch --parsable --dependency=afterok:$JOB_06 07a_annotation.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_07a --wrap \
"echo \"\$(date): Completed script: 07a_annotation.sh\" >> '$LOG'"


# 07b_annotation_visualisation

# Execute script
JOB_07b=$(sbatch --parsable --dependency=afterok:$JOB_07a 07b_annotation_visualisation.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_07b --wrap \
"echo \"\$(date): Completed script: 07b_annotation_visualisation.sh\" >> '$LOG'"



## 8. Genome assembly alignment to reference genome


# 08_alignment

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/08_alignment"

# Execute script
JOB_08=$(sbatch --parsable --dependency=afterok:$JOB_07b 08_alignment.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_08 --wrap \
"echo \"\$(date): Completed script: 08_alignment.sh\" >> '$LOG'"


## 9. Variant analysis


# 09a_variant_calling

# Navigate to script directory
cd "${PROJECT_ROOT}/scripts/09_variation"

# Execute script
JOB_09a=$(sbatch --parsable --dependency=afterok:$JOB_08 09a_variant_calling.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_09a --wrap \
"echo \"\$(date): Completed script: 09a_variant_calling.sh\" >> '$LOG'"


# 09b_variant_filter

# Execute script
JOB_09b=$(sbatch --parsable --dependency=afterok:$JOB_09a 09b_variant_filter.sh)

# Record completion of script in log file
sbatch --dependency=afterok:$JOB_09b --wrap \
"echo \"\$(date): Completed script: 09b_variant_filter.sh\" >> '$LOG'"


# Record completion of pipeline in log file
sbatch --dependency=afterok:$JOB_09b --wrap \
"echo \"Pipeline Completed.\" >> '$LOG'"


