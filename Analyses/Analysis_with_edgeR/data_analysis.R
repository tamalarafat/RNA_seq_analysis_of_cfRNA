# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_markers <- list.files("/home/ytamal2/Documents/2023/PhD_projects_Yasir/scExplorer/Functions/Functions_marker_identification", pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_markers, source, .GlobalEnv)

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_2 <- list.files("/home/ytamal2/Documents/2023/PhD_projects_Yasir/scExplorer/Functions/Functions_matrix_manipulation", pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_2, source, .GlobalEnv)

# Load the count data
counts = loadRData("/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Data/all_samples_count/all_samples_data.RData")

# Filterout genes if expression was not detected in all the samples
counts = counts[rowSums(counts[, -1] == 0) != 72, ]

# Load the Gene symbol (HGNC approved gene symbol (from Ensembl xref pipeline))
gene_meta_data = read.delim("/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Data/Gene_meta_data/gene_info.txt", sep = "", header = FALSE)

# Assign column names to the metadata table
colnames(gene_meta_data) = c("Geneid", "gene_name")

# Process the gene ids
gene_meta_data$Geneid <- sub(pattern = "\\..*", replacement = "", x = gene_meta_data$Geneid)

# Get all the protein coding gene ids
geneset = gene_meta_data[gene_meta_data$gene_name == "protein_coding", "Geneid"]

# Remove rows (genes) with redundant information, in this case - protein_coding
gene_meta_data = gene_meta_data[(gene_meta_data$Geneid %in% geneset) & (gene_meta_data$gene_name != "protein_coding"), ]

# Subset the metadata
gene_meta_data = gene_meta_data[, c(1, 2)]

# Subset the genes to keep only those genes present in the RNA-seq data
gene_meta_data = gene_meta_data[gene_meta_data$Geneid %in% rownames(counts), ]

# Set the rownames to default
rownames(gene_meta_data) <- NULL

# Load the sample metadata
sample_meta_data <- read.delim("/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Data/SRA_accession/Downloaded_accession_files/SraRunTable.txt", sep = ",", stringsAsFactors = FALSE)

# Keep only those samples and disease information used in this analysis
sample_meta_data <- sample_meta_data[sample_meta_data$Run %in% colnames(counts[, -1]), c("Run", "disease")]

# Rewrite the disease information
sample_meta_data$disease <- ifelse(sample_meta_data$disease == "", "control", "disease")

# Set the rownames to default
rownames(sample_meta_data) <- NULL

# Subset the count data to keep only the protein coding genes
counts = counts[rownames(counts) %in% gene_meta_data$Geneid, ]

# Add gene name information to the count table
counts <- counts %>% 
  select(Geneid, everything()) %>%  # Select "Geneid" as the first column
  left_join(gene_meta_data, by = "Geneid")  # Join with gene_meta_data


