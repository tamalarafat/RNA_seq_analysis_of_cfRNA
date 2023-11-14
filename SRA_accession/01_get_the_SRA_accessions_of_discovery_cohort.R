# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_markers <- list.files("/home/ytamal2/Documents/2023/PhD_projects_Yasir/scExplorer/Functions/Functions_marker_identification", pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_markers, source, .GlobalEnv)

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_2 <- list.files("/home/ytamal2/Documents/2023/PhD_projects_Yasir/scExplorer/Functions/Functions_matrix_manipulation", pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_2, source, .GlobalEnv)

# Lets load the metadata
metainfo <- read.delim("/home/ytamal2/Documents/2023/PhD_projects_Yasir/RNA_seq_analysis_of_cfRNA/Supplementary_data/Data/Accession_number/SraRunTable.txt", sep = ",", stringsAsFactors = FALSE)

metainfo$sampleID = gsub(pattern = ".*_", "", metainfo$Sample.Name)

metainfo$gestation_Age = gsub(pattern = "\\D", "", metainfo$Age)

sra_subset = metainfo[metainfo$sampleID == 1, ]

sra_subset = sra_subset[, c("Run", "gestation_Age", "sampleID", "disease", "Age", "Bases", "BioProject", "BioSample", "Bytes", "Experiment", "isolate", "Library.Name", "Sample.Name", "SRA.Study")]

sra_subset = sra_subset[sra_subset$disease != "severe pre-eclampsia", ]

