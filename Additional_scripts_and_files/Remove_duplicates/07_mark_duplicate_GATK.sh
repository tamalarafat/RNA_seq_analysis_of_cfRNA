#!/bin/bash

# Path to the text file containing all sample names
SAMPLE_FILE="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/QCT/SRA_accession_IDs.txt"

mkdir Job_scripts

# Path to the directory where you want to store the job scripts
JOB_SCRIPT_DIR="Job_scripts"

# Path to the directory containing your input FASTQ files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/aligned_reads"

mkdir aligned_reads

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Sorted_bams"

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
    
    echo "I1=\"${INPUT_DIR}/${SAMPLE}_alignment_Aligned.out.sam\"" >> "$JOB_SCRIPT"
    echo "O1=\"${OUTPUT_DIR}/${SAMPLE}_alignment_Aligned.sorted.bam\"" >> "$JOB_SCRIPT"

    # Sort the aligned sam files
    echo "samtools sort -@ 4 \"\${I1}\" -o \"\${O1}\"" >> "$JOB_SCRIPT"
    
    # Index the sorted bam files
    echo "samtools index \"\${O1}\"" >> "$JOB_SCRIPT"
  done

    # Make the job script executable
    chmod +x "$JOB_SCRIPT"
    
    # job submission part
    bsub -q deptsiantis -n 10 -R 'rusage[mem=30000]' -M 300000 -o sort_aligned_reads -e sort_aligned_reads_error.log -J sortreads "$JOB_SCRIPT"
    
    done
