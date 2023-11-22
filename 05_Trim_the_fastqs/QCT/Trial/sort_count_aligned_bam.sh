#!/bin/bash

# Path to the directory containing aligned bam files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/aligned_reads"

mkdir -p "/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/trial/try2/counts"

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/trial/try2/counts"

REF_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/hg38/annotation_file/gencode.v44.basic.annotation.gtf"

I1="${INPUT_DIR}/SRR17333021_sorted_Aligned.sortedByCoord.out.bam"

O1="${OUTPUT_DIR}/SRR17333021_name_sorted.bam"

O2="${OUTPUT_DIR}/SRR17333021_nsorted_aligned_counts.txt"


samtools sort -n -@ 4 "${I1}" -o "${O1}"

featureCounts -T 5 -p --countReadPairs -t exon -g gene_id -a "${REF_DIR}" -o "${O2}" "${O1}"