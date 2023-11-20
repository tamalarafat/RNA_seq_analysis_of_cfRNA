#!/bin/bash

# Path to the text file containing all sample names
SAMPLE_FILE="SRA_accession_IDs.txt"

# create a folder to store the sample ids in batches
mkdir sample_ids

# Output directory for batch files
OUTPUT_DIR="sample_ids"

# Number of samples in each batch
BATCH_SIZE=6

# Read sample names from the file
IFS=$'\n' read -d '' -r -a SAMPLE_NAMES < "$SAMPLE_FILE"

# Calculate the number of batches
NUM_BATCHES=$(( ( ${#SAMPLE_NAMES[@]} + BATCH_SIZE - 1 ) / BATCH_SIZE ))
  
  # Loop through each batch
  for ((i = 0; i < NUM_BATCHES; i++)); do
  # Calculate the start and end index for the current batch
  START_INDEX=$((i * BATCH_SIZE))
  END_INDEX=$((START_INDEX + BATCH_SIZE - 1))
  
  # Create a batch file for the current batch
  BATCH_FILE="$OUTPUT_DIR/batch_$((i + 1)).txt"
  
  # Print the sample names for the current batch to the batch file
  for ((j = START_INDEX; j <= END_INDEX && j < ${#SAMPLE_NAMES[@]}; j++)); do
    echo "${SAMPLE_NAMES[j]}" >> "$BATCH_FILE"
    done
    done
    