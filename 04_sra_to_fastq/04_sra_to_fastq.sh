#!/bin/bash

# Specify LSF job parameters
# -q: queue name
# -n: number of CPU cores
# -R: resource requirements
# -M: memory requirements
# -o: output file for standard output
# -e: output file for standard error
# -J: job name

BSUB_CMD="bsub -q multicore20 -n 8 -R 'rusage[mem=30000]' -M 300000 -o conversion_output -e conversion_error -J sra_to_fastq"

# Execute the bsub command
$BSUB_CMD << EOF
# Load SRA Toolkit module (adjust the module command based on your cluster's configuration)
module load sratoolkit

# Path to the directory containing SRA files
SRA_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/SRA_toolkit/temp/sra"

# Path to the directory where you want to store the FASTQ files
FASTQ_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/rna_fastqs"

# Iterate through each SRA file in the directory and convert to FASTQ
for SRA_FILE in \${SRA_DIR}/*.sra; do
    # Extract the SRA file name without extension
    SRA_BASE=\$(basename -- "\${SRA_FILE%.*}")
    
    # Run fastq-dump for each SRA file
    fastq-dump --outdir \${FASTQ_DIR} --gzip --split-files \${SRA_FILE}

    echo "Converted \${SRA_BASE} to FASTQ."
done
EOF
