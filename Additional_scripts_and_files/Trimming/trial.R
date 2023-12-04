#!/bin/bash

# Script to submit Trimmomatic jobs for paired-end FASTQ files

# Path to the directory containing your input FASTQ files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/trial"

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/trial/qc_fastqs"

BSUB_CMD="bsub -q deptsiantis -n 10 -R 'rusage[mem=30000]' -M 300000 -o trim_output -e trim_error.log -J trim_fastq"

# Execute the bsub command
$BSUB_CMD << EOF

# Iterate through each fastq file in the directory and trim them
for R1 in "${INPUT_DIR}"/*_1.fastq.gz; do
# Extract the sample name from the R1 file
SAMPLE=$(basename "${R1}" _1.fastq.gz)

# Construct paths to input FASTQ files
R2="${INPUT_DIR}/${SAMPLE}_2.fastq.gz"

# Run Trimmomatic for each sample
java jar trimmomatic PE -threads 10 -phred33 \
"${R1}" "${R2}" \
"${OUTPUT_DIR}/${SAMPLE}_1.paired.fastq.gz" "${OUTPUT_DIR}/${SAMPLE}_1.unpaired.fastq.gz" \
"${OUTPUT_DIR}/${SAMPLE}_2.paired.fastq.gz" "${OUTPUT_DIR}/${SAMPLE}_2.unpaired.fastq.gz"

echo "Submitted job for ${SAMPLE} for trimming."
done
EOF
