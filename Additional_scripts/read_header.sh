 grep -E '^##' "/netscratch/dep_tsiantis/grp_laurent/tamal/2023/QC_Library/hg38/annotation_file/gencode.v44.basic.annotation.gtf" | sed 's/## //' | tr '\t' '\n'
