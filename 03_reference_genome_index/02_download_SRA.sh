#!/bin/bash

# Specify job parameters
# -q: queue name
# -n: number of CPU cores
# -R: resource requirements
# -M: memory requirements
# -o: output file for standard output
# -e: output file for standard error
# -J: job name
    
# Save the bsub command as a variable
BSUB_CMD="bsub -q deptsiantis -n 5 -R 'rusage[mem=4280]' -M 300000 -o indrefo -e indrefe -J indref"

# Execute the bsub command
$BSUB_CMD << EOF
# Run STAR indexing with multithreading
STAR --runMode genomeGenerate \
     --genomeDir /netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/hg38/refgenome_index \
     --genomeFastaFiles hg38.fa \
     --runThreadN 8  # Adjust this number based on the cpus-per-task value
EOF
