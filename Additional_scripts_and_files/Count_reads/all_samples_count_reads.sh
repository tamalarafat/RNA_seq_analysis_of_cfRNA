#!/bin/bash

# Path to the text file containing all sample names
SAMPLE_FILE="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/QCT/SRA_accession_IDs.txt"

# Path to the directory containing your input FASTQ files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/aligned_reads"

mkdir -p "/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Counts_aligned_data"

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Counts_aligned_data"

# Define the path to the annotation file (GTF format)
ANNOTATION_FILE="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/hg38/annotation_file/gencode.v44.basic.annotation.gtf"

BSUB_CMD="bsub -q deptsiantis -n 20 -R 'rusage[mem=30000]' -M 300000 -o ASCout -e ASC_error.log -J AScount2"

# Get all the bam file names
I1="${INPUT_DIR}/*.bam"

# Output file name - count matrix
O1="${OUTPUT_DIR}/all_samples_counts_dept.txt"

# Execute the bsub command
$BSUB_CMD << EOF

# Run HTSeq count on the merged BAM file
featureCounts -T 20 -p --countReadPairs -t exon -g gene_id -a "${ANNOTATION_FILE}" -o "${O1}" ${I1}

EOF

