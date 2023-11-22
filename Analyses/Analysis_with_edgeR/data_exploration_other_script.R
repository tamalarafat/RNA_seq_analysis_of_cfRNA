library(dplyr)
library(purrr)

# Input directory containing all the files
input_dir <- "/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Data/per_sample_counts/counts/"

# Get a list of input files
input_files <- list.files(path = input_dir, pattern = "_counts.txt", full.names = TRUE)

# Read and process each file, then bind the rows
combined_df <- input_files %>%
  map_df(~{
    read.delim(.x) %>%
      select(Geneid, matches("_sorted_Aligned.sortedByCoord.out.bam")) %>%
      rename_all(~sub(pattern = "\\_.*", replacement = "", basename(.)))
  }, .id = "file")

# Extract gene IDs without the dot and anything after it
combined_df$Geneid <- sub(pattern = "\\..*", replacement = "", combined_df$Geneid)

# Print the resulting combined dataframe
print(combined_df)
