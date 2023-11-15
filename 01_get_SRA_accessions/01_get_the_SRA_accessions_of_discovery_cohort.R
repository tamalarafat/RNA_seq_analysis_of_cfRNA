project_dir = "/home/yasir/Documents/Projects_Yasir/"

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_markers <- list.files(paste0(project_dir, "scExplorer/Functions/Functions_marker_identification"), pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_markers, source, .GlobalEnv)

# Load all the functions stored in scripts from the folder housing the scripts
scripts_list_2 <- list.files(paste0(project_dir, "scExplorer/Functions/Functions_matrix_manipulation"), pattern = "*.R$", full.names = TRUE) 
sapply(scripts_list_2, source, .GlobalEnv)

# Lets load the metadata
metainfo <- read.delim(paste0(project_dir, "RNA_seq_analysis_of_cfRNA/Supplementary_data/Data/Accession_number/SraRunTable.txt"), sep = ",", stringsAsFactors = FALSE)

metainfo$sampleID = gsub(pattern = ".*_", "", metainfo$Sample.Name)

metainfo$gestation_Age = gsub(pattern = "\\D", "", metainfo$Age)

sra_subset = metainfo[metainfo$sampleID == 1, ]

sra_subset = sra_subset[, c("Run", "gestation_Age", "sampleID", "disease", "Age", "Bases", "BioProject", "BioSample", "Bytes", "Experiment", "isolate", "Library.Name", "Sample.Name", "SRA.Study")]

sra_subset = sra_subset[sra_subset$disease != "severe pre-eclampsia", ]

# For control, get all the samples with gestation age 10, 11, and 12 that sum upto 59 samples
table(sra_subset[sra_subset$gestation_Age %in% c(10, 11, 12) & sra_subset$disease == "", ]$gestation_Age)

control = sra_subset %>% filter(gestation_Age %in% c(10, 11, 12)) %>% filter(disease == "") %>% group_by(gestation_Age) %>%
  sample_n(size = case_when(
    gestation_Age == 10 ~ 15,
    gestation_Age == 11 ~ 24,
    gestation_Age == 12 ~ 20,
    TRUE ~ 0
  ))

# For control, get all the samples with gestation age 10, 11, and 12 that sum upto 59 samples
table(sra_subset[sra_subset$gestation_Age %in% c(10, 11, 12) & sra_subset$disease == "pre-eclampsia", ]$gestation_Age)

disease = sra_subset[sra_subset$gestation_Age %in% c(10, 11, 12) & sra_subset$disease == "pre-eclampsia", ]

# Let's put together the accession ids
sra_acc = c(control$Run, disease$Run)

# Let's save the accession ids to run on the cluster
fileGenerator(sra_acc, "SRA_accession_IDs.txt")
