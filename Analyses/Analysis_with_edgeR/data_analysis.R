library(edgeR)
library(limma)

projects_dir = "~/Documents/Projects_Yasir/"

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_markers <- list.files(paste0(projects_dir, "scExplorer/Functions/Functions_marker_identification"), pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_markers, source, .GlobalEnv)

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_2 <- list.files(paste0(projects_dir, "scExplorer/Functions/Functions_matrix_manipulation"), pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_2, source, .GlobalEnv)

# Load the count data
counts = loadRData(paste0(projects_dir, "RNA_seq_analysis_of_cfRNA/Data/all_samples_count/all_samples_data.RData"))

# Samples names are in SRA accession ids
sample_ids = colnames(counts[, -1])

# Filterout genes if expression was not detected in all the samples
counts = counts[rowSums(counts[, -1] == 0) != 72, ]

# convert character readcounts as numeric values
counts[, -1] <- apply(counts[, -1], 2, as.numeric)

# Load the Gene symbol (HGNC approved gene symbol (from Ensembl xref pipeline))
gene_meta_data = read.delim(paste0(projects_dir, "RNA_seq_analysis_of_cfRNA/Data/Gene_meta_data/gene_info.txt"), sep = "", header = FALSE)

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
sample_meta_data <- read.delim(paste0(projects_dir, "RNA_seq_analysis_of_cfRNA/Data/SRA_accession/Downloaded_accession_files/SraRunTable.txt"), sep = ",", stringsAsFactors = FALSE)

# Keep only those samples and disease information used in this analysis
sample_meta_data <- sample_meta_data[ , c("Run", "disease")]

# Rewrite the disease information
sample_meta_data$disease <- ifelse(sample_meta_data$disease == "", "control", "disease")

# Keep a tab on the disease set
disease_ids = sample_meta_data[(sample_meta_data$disease == "disease") & (sample_meta_data$Run %in% sample_ids), 1]

# Set the rownames to default
rownames(sample_meta_data) <- sample_meta_data$Run

# subset the sample metadata information such as it matches the colnames or sample ids of the counts data
sample_meta_data = sample_meta_data[sample_ids, ]

# Subset the count data to keep only the protein coding genes
counts = counts[rownames(counts) %in% gene_meta_data$Geneid, ]

# Add gene name information to the count table
counts = merge(counts, gene_meta_data, by = "Geneid")

# get the Geneid and gene_name column index
id_index = grep(pattern = "Geneid", x = colnames(counts))
name_index = grep(pattern = "gene_name", x = colnames(counts))

# set the rownames of the count table
rownames(counts) <- str_c(counts$Geneid, counts$gene_name, sep = "_")

# re-arrane the columns of the data table
# counts = counts[, c(id_index, name_index, setdiff(seq(1:ncol(counts)), c(id_index, name_index)))]
# save(counts, file = "RNAseq_table_of_PE.RData")

# Remome the geneID and geneName columns
counts = counts[, -c(id_index, name_index)]

# Confirming samples are in the same order in the gene counts and design table
summary(colnames(counts) == sample_meta_data$Run)

# Conver the count dataframe into matrix class
mat = as.matrix(counts)

# Creating a edgeR object, DGEList object, using the counts
analysis.object <- DGEList(counts = mat, genes = rownames(mat))

# Add grouping information to the object
analysis.object$samples$group <- as.factor(sample_meta_data$disease)

# double check if the groups were assigned correctly
summary(rownames(analysis.object$samples)[analysis.object$samples$group == "disease"] == disease_ids)

# Calculate counts per million - library size normalization
countsPerMillion <- cpm(analysis.object)

summary(countsPerMillion)

# Deploy filtering criterias

# Filter 1 - CPM count has to be 0.5 or more
# Filter 2 - 0.5 CPM count has to be detected in more than 75 samples
genes_to_keep <- rowSums(countsPerMillion >= 1) >= (75 * 72)/100

keep <- which(rowSums(countsPerMillion >= 1) >= (75 * 72)/100)

# Filtering the data
analysis.object <- analysis.object[genes_to_keep, , keep.lib.sizes = FALSE]

summary(cpm(analysis.object)) 

# Calculating normalisation factors
analysis.object <- calcNormFactors(analysis.object, method = "TMM")

plotMDS(analysis.object)

# Estimating common dispersion and tagwise dispersion
groups <- analysis.object$samples$group

model.matrix(~groups)

analysis.object <- estimateDisp(analysis.object,
                               design = model.matrix(~groups))

