# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_markers <- list.files("/home/ytamal2/Documents/2023/PhD_projects_Yasir/scExplorer/Functions/Functions_marker_identification", pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_markers, source, .GlobalEnv)

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_2 <- list.files("/home/ytamal2/Documents/2023/PhD_projects_Yasir/scExplorer/Functions/Functions_matrix_manipulation", pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_2, source, .GlobalEnv)

# Input directory containing all the files
input_dir = "/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Data/per_sample_counts/counts/"

input_files = list.files(path = input_dir, pattern = "_counts.txt", full.names = TRUE)

# create an empty dataset to add the counts of the sample
combined_df = data.frame()

for (i in c(1:length(input_files))) {
  
  # Load the data for samples
  sample <- read.delim(input_files[i], sep = "")
  
  # Set column names to the first row of the data
  colnames(sample) <- sample[1, ]
  
  # Remove the first row (header) and select specific columns (1st and 7th)
  sample <- sample[-1, c("Geneid", colnames(sample)[grep(x = colnames(sample), pattern = "_sorted_Aligned.sortedByCoord.out.bam")])]
  
  # Extract gene IDs without the dot and anything after it
  sample$Geneid <- sub(pattern = "\\..*", replacement = "", sample$Geneid)
  
  # Extract sample names without underscores and anything after them
  colnames(sample)[grep(x = colnames(sample), pattern = "_sorted_Aligned.sortedByCoord.out.bam")] <- sub(pattern = "\\_.*", replacement = "", basename(colnames(sample)[grep(x = colnames(sample), pattern = "_sorted_Aligned.sortedByCoord.out.bam")]))
  
  if (ncol(combined_df) == 0){
    combined_df = sample
  }
  
  else {
    combined_df = merge(combined_df, sample, by = "Geneid")
  }
  
  rownames(combined_df) <- combined_df$Geneid
  
}

save(combined_df, file = "combined_samples_data.RData")


# All samples
all_samples = read.delim("/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Data/all_samples_count/all_samples_counts_dept.txt", sep = "")

colnames(all_samples) = all_samples[1, ]

all_samples = all_samples[-1, ]

all_samples$Geneid = sub(pattern = "\\..*", replacement = "", all_samples$Geneid)

rownames(all_samples) = all_samples$Geneid

all_samples = all_samples[, c("Geneid", colnames(all_samples)[grep(x = colnames(all_samples), pattern = "_sorted_Aligned.sortedByCoord.out.bam")])]

colnames(all_samples) = sub(pattern = "\\_.*", replacement = "", basename(colnames(all_samples)))

save(all_samples, file = "all_samples_data.RData")
´