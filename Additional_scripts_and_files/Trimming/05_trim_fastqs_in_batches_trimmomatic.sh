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

# Number of samples in each batch
BATCH_SIZE=6

# Number of batches
NUM_BATCHES=$(( (72 + BATCH_SIZE - 1) / BATCH_SIZE ))

BSUB_CMD="bsub -q deptsiantis -n 10 -R 'rusage[mem=30000]' -M 300000 -o trim_output -e trim_error.log -J trim_fastq"

# Loop through each batch
for ((i = 1; i <= NUM_BATCHES; i++)); do
    BATCH_START=$(( (i - 1) * BATCH_SIZE + 1 ))
    BATCH_END=$(( i * BATCH_SIZE ))

    # Execute the bsub command for the current batch
    $BSUB_CMD << EOF
    for SAMPLE_INDEX in \$(seq $BATCH_START $BATCH_END); do
        R1="${INPUT_DIR}/SRR${SAMPLE_INDEX}_1.fastq.gz"
        SAMPLE=\$(basename "\${R1}" _1.fastq.gz | cut -d'_' -f1)
        R2="${INPUT_DIR}/${SAMPLE}_2.fastq.gz"

        echo "Processing sample: \${SAMPLE}"
        echo "R1 path: \${R1}"
        echo "R2 path: \${R2}"

        # Rest of your processing...
        # Run Trimmomatic for each sample
        java -jar /netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 10 -phred33 "\${R1}" "\${R2}" "${OUTPUT_DIR}/${SAMPLE}_1.paired.fastq.gz" "${OUTPUT_DIR}/${SAMPLE}_1.unpaired.fastq.gz" "${OUTPUT_DIR}/${SAMPLE}_2.paired.fastq.gz" "${OUTPUT_DIR}/${SAMPLE}_2.unpaired.fastq.gz" ILLUMINACLIP:/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

        echo "Submitted job for \${SAMPLE} for trimming."
    done
EOF
done
