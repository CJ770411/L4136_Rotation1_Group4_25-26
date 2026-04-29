#!/usr/bin/env bash

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1 
#SBATCH --cpus-per-task=1
#SBATCH --mem=2g
#SBATCH --time=00:10:00
#SBATCH --job-name=01a_create_sample_list
#SBATCH --output=../../logs/slurm-%x-%j.out

##########################

## Author: Chris Janschke
## Date: 29.04.2026
## Description: Script to create "sample_list.txt" containing the samples to be tested in this analysis

## Usage: 
#	Execute from script directory 

## Command descriptions:
#  See script README for detailed command description and other useful information.

## Samples for analysis:
# Sample 1
# Sample 4

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
SCRIPT=${PROJECT_ROOT}/scripts/01_preprocessing/01a_create_sample_list.sh
if [ ! -f "$SCRIPT" ]; then
   echo "Error: script must be called from the directory containing the script."
   echo "       Use \"cd <PROJECT_ROOT>/scripts/<SCRIPT_DIRECTORY>\" then re-run the script"
   exit 1
fi

# Define samples
SAMPLE1="sample1"
SAMPLE4="sample4"

# Initiating file creation
echo "Creating text file containing ${SAMPLE1} and ${SAMPLE4}"

# Write sample names to text file
printf "%s\n" "$SAMPLE1" "$SAMPLE4" > "${PROJECT_ROOT}/sample_list.txt"

# Confirming completion
echo "Creating text file containing ${SAMPLE1} and ${SAMPLE4}: Completed"

# Display contents of the file
echo "Here is the contents of the text file"
cat "${PROJECT_ROOT}/sample_list.txt"
