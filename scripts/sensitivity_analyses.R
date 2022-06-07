## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls())


## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

wd <- getwd()
dir.create(file.path(wd, "outputs/sensitivity"))


## ----include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
source(file = "scripts/package_check.R")

packages <- c("data.table",
              "jtools",
              "knitr",
              "gtsummary",
              "broom",
              "sandwich",
              "tidyverse",
              "ggplot2",
              "dplyr",
              "sgof",
              "TwoSampleMR",
              "qvalue",
              "kableExtra",
              "vroom",
              "openxlsx",
              "cowplot",
              "gridGraphics")

package_check(packages)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
source("scripts/GSMR_read.R")


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)

hh <- paste(unlist(args),collapse=' ')
listoptions <- unlist(strsplit(hh,'--'))[-1]
options.args <- sapply(listoptions,function(x){
         unlist(strsplit(x, ' '))[-1]
        })
options.names <- sapply(listoptions,function(x){
  option <-  unlist(strsplit(x, ' '))[1]
})
names(options.args) <- unlist(options.names)
print(options.args)

phenotype <- args[1]


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dir.create(file.path(wd, "outputs/sensitivity/protein_exposure"))
dir.create(file.path(wd, "outputs/sensitivity/protein_exposure/gsmr_out"))
output_dir <- paste0(wd, "/outputs/sensitivity/protein_exposure/gsmr_out")

sig_protein_exposure <- readWorkbook(xlsxFile = "outputs/main_GSMR_output.xlsx", sheet = "chart_protein_exposure")

sig_protein_exposure$study <- tolower(sig_protein_exposure$study)
sig_protein_exposure$file_name <- gsub(".gsmr", "", sig_protein_exposure$file_name)

filename <- sig_protein_exposure$file_name
study <- sig_protein_exposure$study
sig_protein_exposure$Exposure <- make.names(sig_protein_exposure$Exposure,unique=T)
marker <- sig_protein_exposure$Exposure
outcome <- sig_protein_exposure$Outcome
path <- wd
label <- paste(sig_protein_exposure$Exposure, sig_protein_exposure$study, sep = "_")
# no_dups <- make.unique(label, sep = ".")

number <- 1

rm(wb)

wb <- createWorkbook()

for(number in 1:length(filename)){

  current_marker <- filename[number]

  file_path_gsmr <- paste0(path,"/",study[number],"_mr/output/",current_marker,".eff_plot.gz")

  gsmr_data <- read_gsmr_data(file_path_gsmr)

  gsmr_data$pheno[3] <- label[number]
  gsmr_data$bxy_result[1] <- label[number]
  gsmr_data$bxy_result[4] <- label[number]

  graph <- plot_gsmr_effect(gsmr_data,label[number],paste0(phenotype), colors()[75])

  ggsave(filename = paste0(label[number]), plot = graph, path = output_dir, width = 6, height = 4, device='tiff', dpi=700)

  snp_data <- gsmr_snp_effect(gsmr_data,label[number],paste0(phenotype))

  snp_data <- as.data.frame(snp_data)

  # current_name <- substring(paste0(names[number]), 1, 30)

  addWorksheet(wb, sheetName = paste0(label[number]))

  writeData(wb, sheet = paste0(label[number]), snp_data, rowNames = TRUE)

}

saveWorkbook(wb, file = paste0(wd,"/outputs/sensitivity/protein_exposure/protein_exposure_gsmr.xlsx"), overwrite = TRUE)



## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dir.create(file.path(wd, "outputs/sensitivity/protein_exposure/2SMR_out"))
output_dir <- paste0(wd, "/outputs/sensitivity/protein_exposure/2SMR_out")

sig_protein_exposure <- readWorkbook(xlsxFile = "outputs/main_GSMR_output.xlsx", sheet = "chart_protein_exposure")

sig_protein_exposure$study <- tolower(sig_protein_exposure$study)
sig_protein_exposure$file_name <- gsub(".gsmr", "", sig_protein_exposure$file_name)

filename <- sig_protein_exposure$file_name
study <- sig_protein_exposure$study
names <- sig_protein_exposure$names
sig_protein_exposure$Exposure <- make.names(sig_protein_exposure$Exposure,unique=T)
marker <- sig_protein_exposure$Exposure
outcome <- sig_protein_exposure$Outcome
path <- wd
label <- paste(sig_protein_exposure$Exposure, sig_protein_exposure$study, sep = "_")
all_protein <- list.files(paste0(path,"/outputs/sensitivity/protein_exposure/gsmr_out"), include.dirs = F)

# no_dups <- make.unique(label, sep = ".")

number <- 1

rm(wb)

wb <- createWorkbook()

# Make the columns as follows:
# SNP
# beta
# SE
# effect_allele
# non-effective allele
# p-value
# effect_allele freq

#using TwoSampleMR, read in the outcome of interest
outcome_dat <- read_outcome_data(
  filename = paste0(wd,"/",phenotype,".txt"),
  sep = " ",
  snp_col = "SNP",
  beta_col = "BETA",
  se_col = "SE",
  effect_allele_col = "A1",
  other_allele_col = "A2",
  eaf = "MAF",
  samplesize_col = "N",
  pval_col = "P")

  outcome_dat$outcome=paste0("AD_Schwartzentruber")

for(number in 1:length(filename)){

  #read in the workbook with all our significant proteins
  current_protein <- readWorkbook(xlsxFile = paste0(wd, "/outputs/sensitivity/protein_exposure/protein_exposure_gsmr.xlsx"), sheet = paste0(label[number]), rowNames = TRUE)

  #get the SNPs of interest
  df <- current_protein %>%
    select(SNP = snp)

  #get the whole GWAS from the same protein
  original_protein <- vroom(paste0("/scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/",filename[number],".gz"))

  #join the shorter and the longer protein data together
  full_df <-  inner_join(df, original_protein)

  #get all the columns that we need
  try(
    full_df <- full_df %>%
  select(SNP, BETA, SE, A1, A2, P, MAF)
  )
  try(
    full_df <- full_df %>%
  select(SNP, BETA, SE = STDERR, A1, A2, P, MAF)
  )

  #get all the columns that we need
  full_df <- full_df %>%
  select(SNP,
         beta = BETA,
         se = SE,
         effect_allele = A1,
         other_allele = A2,
         eaf = MAF
         )

  #format
  exposure_dat <- format_data(full_df, type = "exposure")

  exposure_dat$exposure=paste0(label[number])

  #Harmonisation of SNP instruments between exposures and outcomes
  harmonized <- harmonise_data(exposure_dat = exposure_dat, outcome_dat = outcome_dat, action=2)

  # get the data ready
  # all exposures -> Covid
  dataMR_keep=subset(harmonized, mr_keep==TRUE)

  # perform TwoSampleMR for all pairs
  MR_toCovid_keep<- mr(dataMR_keep)

  #get the name of the current marker and brain volume
  current_name <- substring(paste0(label[number]), 1, 30)

  #add a new sheet to the excel data frame and add the sensitivity data to this sheet
  addWorksheet(wb, sheetName = paste0(current_name))

  writeData(wb, sheet = paste0(current_name), MR_toCovid_keep, rowNames = TRUE)

  #save the results as a data frame
  Results_MR_toCovid_keep=MR_toCovid_keep # Saves the results in dataframe

  #plot the results
  plot = mr_scatter_plot(Results_MR_toCovid_keep, dataMR_keep)

  #just choose the plot from the list elements
  try({save_plot <- plot[[1]]})

  #save plot
  try({ggsave(filename = paste0(label[number]), plot = save_plot, path = output_dir, width = 6, height = 4, device='tiff', dpi=700)})

}

#save the entire excel workbook with all the sensitivity analyses
saveWorkbook(wb, file = paste0(wd,"/outputs/sensitivity/protein_exposure/protein_exposure_2SMR.xlsx"), overwrite = TRUE)



## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dir.create(file.path(wd, "outputs/sensitivity/protein_outcome"))
dir.create(file.path(wd, "outputs/sensitivity/protein_outcome/gsmr_out"))
output_dir <- paste0(wd, "/outputs/sensitivity/protein_outcome/gsmr_out")

sig_protein_outcome <- readWorkbook(xlsxFile = "outputs/main_GSMR_output.xlsx", sheet = "chart_protein_outcome")

sig_protein_outcome$study <- tolower(sig_protein_outcome$study)
sig_protein_outcome$file_name <- gsub(".gsmr", "", sig_protein_outcome$file_name)

filename <- sig_protein_outcome$file_name
study <- sig_protein_outcome$study
sig_protein_outcome$Outcome<- make.names(sig_protein_outcome$Outcome,unique=T)
marker <- sig_protein_outcome$Outcome
path <- wd
label <- paste(sig_protein_outcome$Outcome, sig_protein_outcome$study, sep = "_")
# no_dups <- make.unique(label, sep = ".")

number <- 1

rm(wb)

wb <- createWorkbook()

for(number in 1:length(filename)){

  current_marker <- filename[number]

  print(filename[number])

  file_path_gsmr <- paste0(path,"/",study[number],"_mr/output/",current_marker,".eff_plot.gz")

  gsmr_data <- read_gsmr_data(file_path_gsmr)

  gsmr_data$pheno[3] <- label[number]
  gsmr_data$bxy_result[1] <- label[number]
  gsmr_data$bxy_result[4] <- label[number]

  graph <- plot_gsmr_effect(gsmr_data,paste0(phenotype),label[number], colors()[75])

  ggsave(filename = paste0(label[number]), plot = graph, path = output_dir, width = 6, height = 4, device='tiff', dpi=700)

  snp_data <- gsmr_snp_effect(gsmr_data,paste0(phenotype),label[number])

  snp_data <- as.data.frame(snp_data)

  addWorksheet(wb, sheetName = paste0(label[number]))

  writeData(wb, sheet = paste0(label[number]), snp_data, rowNames = TRUE)


}

saveWorkbook(wb, file = paste0(wd,"/outputs/sensitivity/protein_outcome/protein_outcome_gsmr.xlsx"), overwrite = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dir.create(file.path(wd, "outputs/sensitivity/protein_outcome/2SMR_out"))
output_dir <- paste0(wd, "/outputs/sensitivity/protein_outcome/2SMR_out")

sig_protein_outcome <- readWorkbook(xlsxFile = "outputs/main_GSMR_output.xlsx", sheet = "chart_protein_outcome")

sig_protein_outcome$study <- tolower(sig_protein_outcome$study)
sig_protein_outcome$file_name <- gsub(".gsmr", "", sig_protein_outcome$file_name)

filename <- sig_protein_outcome$file_name
study <- sig_protein_outcome$study
sig_protein_outcome$Outcome<- make.names(sig_protein_outcome$Outcome,unique=T)
marker <- sig_protein_outcome$Outcome
path <- wd
label <- paste(sig_protein_outcome$Outcome, sig_protein_outcome$study, sep = "_")
# no_dups <- make.unique(label, sep = ".")

# this is only done once to get the smaller AD GWAS
gwas <- vroom(paste0(wd,"/",phenotype,".txt"))

gwas <- gwas %>%
  subset(P<5*10^-8)

write.table(gwas, file = paste0(wd,"/outputs/sensitivity/gwas_pval"), col.names=T, row.names=F, quote=F,sep = "\t")


# Make the columns as follows:
# SNP
# beta
# SE
# effect_allele
# non-effective allele
# p-value
# effect_allele freq

number <- 1

# library(TwoSampleMR)

rm(wb)

wb <- createWorkbook()

for(number in 1:length(filename)){

  #using TwoSampleMR, read in the outcome of interest
  exposure_dat <- read_exposure_data(
  filename = paste0(wd,"/outputs/sensitivity/gwas_pval"),
  sep = "\t",
  snp_col = "SNP",
  beta_col = "BETA",
  se_col = "SE",
  effect_allele_col = "A1",
  other_allele_col = "A2",
  eaf = "MAF",
  samplesize_col = "N",
  pval_col = "P")

  exposure_dat$exposure=paste0(phenotype)

  #read in the workbook with all our significant proteins
  current_protein <- readWorkbook(xlsxFile = paste0(wd,"/outputs/sensitivity/protein_outcome/protein_outcome_gsmr.xlsx"), sheet = paste0(label[number]), rowNames = TRUE)

  #get the whole GWAS from the same protein
  original_protein <- vroom(paste0("/scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/",filename[number],".gz"))

  #get all the columns that we need
  full_df <- original_protein %>%
  select(SNP,
         beta = BETA,
         se = SE,
         effect_allele = A1,
         other_allele = A2,
         eaf = MAF
         )

  #format
  outcome_dat <- format_data(full_df, type = "outcome")

  outcome_dat$outcome=paste0(marker[number])

  exposure_dat <- clump_data(exposure_dat, clump_r2 = 0.05)

  #Harmonisation of SNP instruments between exposures and outcomes
  harmonized <- harmonise_data(exposure_dat = exposure_dat, outcome_dat = outcome_dat, action=2)

  # get the data ready
  # all exposures -> Covid
  dataMR_keep=subset(harmonized, mr_keep==TRUE)

  # perform TwoSampleMR for all pairs
  MR_toCovid_keep<- mr(dataMR_keep)

  #get the name of the current marker and brain volume
  current_name <- substring(paste0(label[number]), 1, 30)

  #add a new sheet to the excel data frame and add the sensitivity data to this sheet
  addWorksheet(wb, sheetName = paste0(current_name))

  writeData(wb, sheet = paste0(current_name), MR_toCovid_keep, rowNames = TRUE)

  #save the results as a data frame
  Results_MR_toCovid_keep=MR_toCovid_keep # Saves the results in dataframe

  #plot the results
  plot = mr_scatter_plot(Results_MR_toCovid_keep, dataMR_keep)

  #just choose the plot from the list elements
  try({save_plot <- plot[[1]]})

  #save plot
  try({ggsave(filename = paste0(label[number]), plot = save_plot, path = output_dir, width = 6, height = 4, device='tiff', dpi=700)})

}

#save the entire excel workbook with all the sensitivity analyses
saveWorkbook(wb, file = paste0(wd,"/outputs/sensitivity/protein_outcome/protein_outcome_2SMR.xlsx"), overwrite = TRUE)
