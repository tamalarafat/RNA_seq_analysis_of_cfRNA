#!/bin/bash

# Specify job parameters
# -q: queue name
# -n: number of CPU cores
# -R: resource requirements
# -M: memory requirements
# -o: output file for standard output
# -e: output file for standard error
# -J: job name

bsub -q deptsiantis -n 5 -R "rusage[mem=4280]" -M 300000 -o srao -e srae -J srad

# Download SRA data
for i in $(cat SRA_accession_IDs.txt); do
  prefetch ${i}
done

# End of script