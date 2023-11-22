#!/bin/bash

# Path to the directory containing aligned bam files
INPUT_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/Marked_duplicated_reads"

mkdir -p counts

# Path to the directory where you want to store the trimmed output
OUTPUT_DIR="counts"

REF_DIR="/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/hg38/annotation_file/gencode.v44.basic.annotation.gtf"

I1="${INPUT_DIR}/_marked_duplicates.bam"

O1="${OUTPUT_DIR}/SRR17333021_marked_counts.txt"
    
featureCounts -a \"${REF_DIR}\" -o \"${O1}\" \"${I1}\"