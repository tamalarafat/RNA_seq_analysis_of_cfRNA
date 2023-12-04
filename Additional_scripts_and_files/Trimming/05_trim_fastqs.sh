#!/bin/bash

# Specify LSF job parameters
# -q: queue name
# -n: number of CPU cores
# -R: resource requirements
# -M: memory requirements
# -o: output file for standard output
# -e: output file for standard error
# -J: job name
# Note: The parameters might vary depending on your cluster configuration

# Path to the directory containing your input FASTQ files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/rna_fastqs"

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/trimmed_rna_fastqs"

BSUB_CMD="bsub -q deptsiantis -n 10 -R 'rusage[mem=30000]' -M 300000 -o trim_output -e trim_error.log -J trim_fastq"

# Execute the bsub command
$BSUB_CMD << EOF

# Iterate through each fastq file in the directory and trim them
for R1 in "${INPUT_DIR}"/*_1.fastq.gz; do
    # Extract the sample name from the R1 file
    SAMPLE=$(basename "${R1}" _1.fastq.gz)

    # Construct paths to input FASTQ files
    R2="${INPUT_DIR}/${SAMPLE}_2.fastq.gz"

    # Run Trim Galore for each sample
    trim_galore --cores 10 --paired --output_dir "${OUTPUT_DIR}" --report_dir "${REPORT_DIR}" "${R1}" "${R2}"

    echo "Submitted job for ${SAMPLE} for trimming."
done
EOF