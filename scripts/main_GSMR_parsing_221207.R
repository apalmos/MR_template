## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls())
Sys.setenv(LANG = "en")

## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

wd <- getwd()


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
pval <- args[2]


## ----include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(data.table)
library(jtools)
library(knitr)
library(broom)
library(sandwich)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(sgof)
#library(TwoSampleMR)
library(qvalue)
#library(kableExtra)
library(vroom)
library(openxlsx)
library(scales)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#get MR function
get_mr <- function(study, dir, extra = NULL){

  if(is.null(extra)){

  current_dir <- dir
  setwd(paste0(current_dir,"/",study,"_mr/output/"))
  list <- list.files(pattern = "*.gsmr")

  if(any(list > 1)) {

  mr <- lapply(list, read.delim)
  bind <- do.call(rbind.data.frame, mr)
  title <- str_to_title(study)
  bind$study <- paste0(title)
  bind$file_name <- rep(list, each=2)

  bind <- bind %>%
    filter(nsnp >= 1)

  bind_n <- count(bind)
  assign(paste0(study,"_mr"),value = bind)

  }
  }

  else

    current_dir <- dir

  setwd(paste0(current_dir,"/",study,"_mr/",extra,"output/"))
  list <- list.files(pattern = "*.gsmr")

  if(any(list > 1)) {

  mr <- lapply(list, read.delim)
  bind <- do.call(rbind.data.frame, mr)
  title <- str_to_title(study)
  bind$study <- paste0(title)
  bind$file_name <- rep(list, each=2)

  bind <- bind %>%
    filter(nsnp >= 1)

  bind_n <- count(bind)
  assign(paste0(study,"_mr"),value = bind)

  }
}


## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sun_mr <- get_mr(study = "sun", dir = wd)
suhre_mr <- get_mr(study = "suhr", dir = wd)
folk_mr <- get_mr(study = "folk", dir = wd)
sliz_mr <- get_mr(study = "sliz", dir = wd)
wood_mr <- get_mr(study = "wood", dir = wd)
ahol_mr <- get_mr(study = "infl", dir = wd)
scal_mr <- get_mr(study = "scal", dir = wd)
hill_mr <- get_mr(study = "hill", dir = wd)
hogl_mr <- get_mr(study = "hogl", dir = wd)
enroth_mr <- get_mr(study = "enroth", dir = wd)
deco_mr <- get_mr(study = "deco", dir = wd)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
wb <- createWorkbook()


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# combine all to make a master df
all_studies <- list(sun_mr)
all_studies <- list(folk_mr, sliz_mr, suhre_mr, sun_mr, wood_mr, ahol_mr, scal_mr, hill_mr, hogl_mr, enroth_mr, deco_mr)
mr_df_all = do.call(rbind, all_studies)


# ## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# prot_exposure <- mr_df_all[mr_df_all$Exposure %like% paste0(phenotype), ]
# nrow(prot_exposure)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mr_df_all$Beta_exponent <- exp(mr_df_all$bxy)
mr_df_all$LCI <- mr_df_all$Beta_exponent - (mr_df_all$se * 1.96)
mr_df_all$UCI <- mr_df_all$Beta_exponent + (mr_df_all$se * 1.96)

mr_df_all$Log_Beta <- log(mr_df_all$Beta_exponent)
mr_df_all$Log_SE <- log(mr_df_all$se)


#Alish: Is this true?
mr_df_all <- mr_df_all %>% 
  mutate(Log_LowerCI = Log_Beta - (se * 1.96),
         Log_UpperCI = Log_Beta + (se * 1.96))


mr_df_all <- mr_df_all %>% 
  rename(Beta = bxy, StandardError = se, Pvalue = p, SNPs = nsnp, LowerCI = LCI, UpperCI =  UCI)

## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_exposure <- mr_df_all[mr_df_all$Outcome %like% paste0(phenotype), ]

#add results to workbook
addWorksheet(wb, sheetName = "all_protein_exposure")
writeData(wb, sheet = "all_protein_exposure", all_prot_exposure, rowNames = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_exposure_filtered <- all_prot_exposure %>%
  filter(SNPs > 2)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pvalues <- all_prot_exposure_filtered$Pvalue
qobj <- qvalue(p = pvalues)
lfdr <- qobj$lfdr


qvalues <- as.matrix(qobj$qvalues)
all_prot_exposure_filtered$qvalue <- cbind(qvalues)



## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
p <- SGoF(all_prot_exposure_filtered$Pvalue)
summary(p)

p_list <- p$Adjusted.pvalues

all_prot_exposure_filtered <- all_prot_exposure_filtered[order(all_prot_exposure_filtered$Pvalue),]
all_prot_exposure_filtered$p_adjusted_SGoF <- p_list



#add results to workbook
addWorksheet(wb, sheetName = "protein_exposure_min_3_snp")
writeData(wb, sheet = "protein_exposure_min_3_snp", all_prot_exposure_filtered, rowNames = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_outcome <- mr_df_all[mr_df_all$Exposure %like% paste0(phenotype), ]

#add results to workbook
addWorksheet(wb, sheetName = "all_protein_outcome")
writeData(wb, sheet = "all_protein_outcome", all_prot_outcome, rowNames = TRUE)

## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_outcome_filtered <- all_prot_outcome %>%
  filter(SNPs > 2)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pvalues <- all_prot_outcome_filtered$Pvalue
qobj <- qvalue(p = pvalues)
lfdr <- qobj$lfdr


qvalues <- as.matrix(qobj$qvalues)
all_prot_outcome_filtered$qvalue <- cbind(qvalues)



## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
p <- SGoF(all_prot_outcome_filtered$Pvalue)
summary(p)

p_list <- p$Adjusted.pvalues

all_prot_outcome_filtered <- all_prot_outcome_filtered[order(all_prot_outcome_filtered$Pvalue),]
all_prot_outcome_filtered$p_adjusted_SGoF <- p_list



#add results to workbook
addWorksheet(wb, sheetName = "protein_outcome_min_3_snp")
writeData(wb, sheet = "protein_outcome_min_3_snp", all_prot_outcome_filtered, rowNames = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dir.create(file.path(wd, "outputs"))
output_dir <- paste0(wd,"/outputs")
saveWorkbook(wb, file = paste0(output_dir,"/main_GSMR_output_",phenotype, ".xlsx"), overwrite = TRUE)
