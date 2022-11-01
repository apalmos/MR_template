## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls())


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
library(TwoSampleMR)
library(qvalue)
library(kableExtra)
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
all_studies <- list(folk_mr, sliz_mr, suhre_mr, sun_mr, wood_mr, ahol_mr, scal_mr, hill_mr, hogl_mr, enroth_mr, deco_mr)
mr_df_all = do.call(rbind, all_studies)


## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
prot_exposure <- mr_df_all[mr_df_all$Exposure %like% paste0(phenotype), ]
nrow(prot_exposure)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mr_df_all$Beta_exponent <- exp(mr_df_all$bxy)
mr_df_all$LCI <- mr_df_all$Beta_exponent - (mr_df_all$se * 1.96)
mr_df_all$UCI <- mr_df_all$Beta_exponent + (mr_df_all$se * 1.96)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pvalues <- mr_df_all$p
qobj <- qvalue(p = pvalues)
lfdr <- qobj$lfdr
summary(qobj)
hist(qobj)
plot(qobj)

qvalues <- as.matrix(qobj$qvalues)
mr_df_all$qvalue <- cbind(qvalues)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
p <- SGoF(mr_df_all$p)
summary(p)

plot(p)

p_list <- p$Adjusted.pvalues

mr_df_all <- mr_df_all[order(mr_df_all$p),]
mr_df_all$p_adjusted_SGoF <- p_list


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_exposure <- mr_df_all[mr_df_all$Outcome %like% paste0(phenotype), ]

#add results to workbook
addWorksheet(wb, sheetName = "sll_protein_exposure")
writeData(wb, sheet = "sll_protein_exposure", all_prot_exposure, rowNames = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_exposure_filtered <- all_prot_exposure %>%
  filter(qvalue < 0.05)

all_prot_exposure_filtered <- all_prot_exposure_filtered %>%
  rename(Beta = bxy, StandardError = se, Pvalue = p, SNPs = nsnp, LowerCI = LCI, UpperCI =  UCI)

all_prot_exposure_filtered <- all_prot_exposure_filtered %>% arrange(desc(Beta_exponent))

all_prot_exposure_filtered$Log_Beta <- log(all_prot_exposure_filtered$Beta_exponent)
all_prot_exposure_filtered$Log_SE <- log(all_prot_exposure_filtered$StandardError)

all_prot_exposure_filtered$Log_LowerCI <- all_prot_exposure_filtered$Log_Beta - (all_prot_exposure_filtered$StandardError * 1.96)
all_prot_exposure_filtered$Log_UpperCI <- all_prot_exposure_filtered$Log_Beta + (all_prot_exposure_filtered$StandardError * 1.96)

#add results to workbook
addWorksheet(wb, sheetName = "sig_protein_exposure")
writeData(wb, sheet = "sig_protein_exposure", all_prot_exposure_filtered, rowNames = TRUE)


## ----fig.width=20, fig.height=40, echo=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------

all_prot_exposure_chart <- all_prot_exposure_filtered %>%
  filter(qvalue < paste0(pval))

all_prot_exposure_chart <- all_prot_exposure_chart[complete.cases(all_prot_exposure_chart), ]

#add suffixt to any duplicated proteins
all_prot_exposure_chart$Exposure <- as.character(all_prot_exposure_chart$Exposure)
all_prot_exposure_chart$Exposure <- make.names(all_prot_exposure_chart$Exposure,unique=T)

#create figure
all_prot_exposure_fig <-
  ggplot(all_prot_exposure_chart, aes(x=reorder(as.factor(Exposure), Beta_exponent) , y=Beta_exponent)) +
    geom_boxplot(fill="slateblue") + coord_flip() + geom_errorbar(aes(ymax = UpperCI, ymin = LowerCI))+ ggtitle("Proteins as Exposure") +
  xlab("Exposure Variable") + ylab("Odds Ratio (95% Confidence Interval)")+ geom_hline(yintercept=1, linetype="dashed", color = "red") +
  theme_bw() + theme(text=element_text(size=25, family="Arial")) +
  geom_hline(linetype = "dashed", yintercept = 1) +
    theme(panel.grid.major.x = element_line(size = 0.5,
                                        linetype = 'dashed',
                                        colour = "gray41"),
        panel.grid.major.y = element_line(size = 0.1,
                                        linetype = 'solid',
                                        colour = "gray62"))

#add results to workbook
addWorksheet(wb, sheetName = "chart_protein_exposure")
writeData(wb, sheet = "chart_protein_exposure", all_prot_exposure_chart, rowNames = TRUE)



## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#example of how to run the extra argument
# sun_mr <- get_mr(study = "sun", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# suhre_mr <- get_mr(study = "suhre", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# folk_mr <- get_mr(study = "folk", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# sliz_mr <- get_mr(study = "sliz", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# wood_mr <- get_mr(study = "wood", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# ahol_mr <- get_mr(study = "ahol", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# scal_mr <- get_mr(study = "scal", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# hill_mr <- get_mr(study = "hill", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# hogl_mr <- get_mr(study = "hogl", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# enroth_mr <- get_mr(study = "enroth", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")
# deco_mr <- get_mr(study = "deco", dir = "/scratch/prj/ukbiobank/usr/alish/AD_MR/", extra = "ADexp/")



## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# combine all to make a master df
# mr_df_all <- rbind(folk_mr, sliz_mr, suhre_mr, sun_mr, wood_mr, ahol_mr, scal_mr, hill_mr, hogl_mr, enroth_mr, deco_mr)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
prot_outcome <- mr_df_all[mr_df_all$Outcome %like% paste0(phenotype), ]
nrow(prot_outcome)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# mr_df_all$Beta_exponent <- exp(mr_df_all$bxy)
# mr_df_all$LCI <- mr_df_all$Beta_exponent - (mr_df_all$se * 1.96)
# mr_df_all$UCI <- mr_df_all$Beta_exponent + (mr_df_all$se * 1.96)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# pvalues <- mr_df_all$p
# qobj <- qvalue(p = pvalues)
# lfdr <- qobj$lfdr
# summary(qobj)
# hist(qobj)
# plot(qobj)
#
# qvalues <- as.matrix(qobj$qvalues)
# mr_df_all$qvalue <- cbind(qvalues)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# p <- SGoF(mr_df_all$p)
# summary(p)
#
# plot(p)
#
# p_list <- p$Adjusted.pvalues
#
# mr_df_all <- mr_df_all[order(mr_df_all$p),]
# mr_df_all$p_adjusted_SGoF <- p_list


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_outcome <- mr_df_all[mr_df_all$Exposure %like% paste0(phenotype), ]

#add results to workbook
addWorksheet(wb, sheetName = "all_protein_outcome")
writeData(wb, sheet = "all_protein_outcome", all_prot_outcome, rowNames = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
all_prot_outcome_filtered <- all_prot_outcome %>%
  filter(qvalue < 0.05)

all_prot_outcome_filtered <- all_prot_outcome_filtered %>%
  rename(Beta = bxy, StandardError = se, Pvalue = p, SNPs = nsnp, LowerCI = LCI, UpperCI =  UCI)

all_prot_outcome_filtered <- all_prot_outcome_filtered %>% arrange(desc(Beta_exponent))

all_prot_outcome_filtered$Log_Beta <- log(all_prot_outcome_filtered$Beta_exponent)
all_prot_outcome_filtered$Log_SE <- log(all_prot_outcome_filtered$StandardError)

all_prot_outcome_filtered$Log_LowerCI <- all_prot_outcome_filtered$Log_Beta - (all_prot_outcome_filtered$StandardError * 1.96)
all_prot_outcome_filtered$Log_UpperCI <- all_prot_outcome_filtered$Log_Beta + (all_prot_outcome_filtered$StandardError * 1.96)

#add results to workbook
addWorksheet(wb, sheetName = "sig_protein_outcome")
writeData(wb, sheet = "sig_protein_outcome", all_prot_outcome_filtered, rowNames = TRUE)


## ----fig.width=20, fig.height=40, echo=FALSE-------------------------------------------------------------------------------------------------------------------------------------------------------------

all_prot_outcome_chart <- all_prot_outcome_filtered %>%
  filter(qvalue < paste0(pval))

all_prot_outcome_chart <- all_prot_outcome_chart[complete.cases(all_prot_outcome_chart), ]

#add suffixt to any duplicated proteins
all_prot_outcome_chart$Exposure <- as.character(all_prot_outcome_chart$Exposure)
all_prot_outcome_chart$Exposure <- make.names(all_prot_outcome_chart$Exposure,unique=T)

#create figure
all_prot_outcome_fig <-
  ggplot(all_prot_outcome_chart, aes(x=reorder(as.factor(Outcome), Beta_exponent) , y=Beta_exponent)) +
    geom_boxplot(fill="slateblue") + coord_flip() + geom_errorbar(aes(ymax = UpperCI, ymin = LowerCI))+ ggtitle("Proteins as Outcomes") +
  xlab("Outcome Variable") + ylab("Odds Ratio (95% Confidence Interval)")+ geom_hline(yintercept=1, linetype="dashed", color = "red") +
  theme_bw() + theme(text=element_text(size=25, family="Arial")) +
  geom_hline(linetype = "dashed", yintercept = 1) +
    theme(panel.grid.major.x = element_line(size = 0.5,
                                        linetype = 'dashed',
                                        colour = "gray41"),
        panel.grid.major.y = element_line(size = 0.1,
                                        linetype = 'solid',
                                        colour = "gray62"))

#add results to workbook
addWorksheet(wb, sheetName = "chart_protein_outcome")
writeData(wb, sheet = "chart_protein_outcome", all_prot_outcome_chart, rowNames = TRUE)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dir.create(file.path(wd, "outputs"))
output_dir <- paste0(wd,"/outputs")
saveWorkbook(wb, file = paste0(output_dir,"/main_GSMR_output.xlsx"), overwrite = TRUE)

#save the plots
ggsave(filename = paste0(output_dir,"/all_prot_exposure_fig"), plot = all_prot_exposure_fig, width = 6, height = 4, device='tiff', dpi=700)
ggsave(filename = paste0(output_dir,"/all_prot_outcome_fig"), plot = all_prot_outcome_fig, width = 6, height = 4, device='tiff', dpi=700)
