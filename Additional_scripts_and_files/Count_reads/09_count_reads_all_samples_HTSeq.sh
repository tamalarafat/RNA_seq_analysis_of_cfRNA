#!/bin/bash

# Path to the directory containing your input bam files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Marked_duplicated_reads"

mkdir -p "/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/htseq_counts"

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/htseq_counts"

# Define the path to the annotation file (GTF format)
ANNOTATION_FILE="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/hg38/annotation_file/gencode.v44.chr_patch_hapl_scaff.basic.annotation.gtf"

BSUB_CMD="bsub -q deptsiantis -n 10 -R 'rusage[mem=30000]' -M 300000 -o trim_output -e trim_error.log -J trim_fastq"

# Get all the bam file names
I1="${INPUT_DIR}/*.bam"

# Output file name - merged bam file
O1="${OUTPUT_DIR}/all_samples_merged.bam"

# Output file name - count matrix
O2="${OUTPUT_DIR}/all_samples_counts.txt"

# Execute the bsub command
$BSUB_CMD << EOF

# Merge all BAM files into a single file
samtools merge -@ 4 "${O1}" "${I1}"

# Run HTSeq count on the merged BAM file
htseq-count -f bam -r pos -t exon -i gene_name "${O1}" "${ANNOTATION_FILE}" > "${O2}"

EOF
