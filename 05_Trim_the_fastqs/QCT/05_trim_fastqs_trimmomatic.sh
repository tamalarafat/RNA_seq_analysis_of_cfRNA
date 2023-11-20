#!/bin/bash

# Path to the text file containing all sample names
SAMPLE_FILE="SRA_accession_IDs.txt"

# Path to the directory where you want to store the job scripts
JOB_SCRIPT_DIR="Job_scripts"

# Path to the directory containing your input FASTQ files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/rna_fastqs"

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/trimmed_rna_fastqs"

# Number of samples in each batch
BATCH_SIZE=6

IFS=$'\n' read -d '' -r -a SAMPLE_NAMES < "$SAMPLE_FILE"

# Calculate the number of batches
NUM_BATCHES=$(( ( ${#SAMPLE_NAMES[@]} + BATCH_SIZE - 1 ) / BATCH_SIZE ))
  
  # Loop through each batch
  for ((i = 0; i < NUM_BATCHES; i++)); do
  # Calculate the start and end index for the current batch
  START_INDEX=$((i * BATCH_SIZE))
  END_INDEX=$((START_INDEX + BATCH_SIZE - 1))
  
  # Create a job script for the current batch
  JOB_SCRIPT="$JOB_SCRIPT_DIR/job_script_batch_$((i + 1)).sh"
  echo "#!/bin/bash" > "$JOB_SCRIPT"
  
  echo "INPUT_DIR=\"$INPUT_DIR\"" >> "$JOB_SCRIPT"
  echo "OUTPUT_DIR=\"$OUTPUT_DIR\"" >> "$JOB_SCRIPT"
  
    # Print the sample names for the current batch and Trimmomatic commands
  for ((j = START_INDEX; j <= END_INDEX && j < ${#SAMPLE_NAMES[@]}; j++)); do
      SAMPLE="${SAMPLE_NAMES[j]}"
      echo "echo 'Processing sample: $SAMPLE'" >> "$JOB_SCRIPT"
  
      R1="${INPUT_DIR}/${SAMPLE}_1.fastq.gz"
      R2="${INPUT_DIR}/${SAMPLE}_2.fastq.gz"
  
      # Run Trimmomatic for each sample
      echo "java -jar /netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 10 -phred33 \"\${R1}\" \"\${R2}\" \"${OUTPUT_DIR}/${SAMPLE}_1.paired.fastq.gz\" \"${OUTPUT_DIR}/${SAMPLE}_1.unpaired.fastq.gz\" \"${OUTPUT_DIR}/${SAMPLE}_2.paired.fastq.gz\" \"${OUTPUT_DIR}/${SAMPLE}_2.unpaired.fastq.gz\" ILLUMINACLIP:/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36" >> "$JOB_SCRIPT"
  done

    
    # Make the job script executable
    chmod +x "$JOB_SCRIPT"
    
    # job submission part
    bsub -q deptsiantis -n 10 -R 'rusage[mem=30000]' -M 300000 -o trim_output -e trim_error.log -J trim_fastq "$JOB_SCRIPT"
    
    done
    