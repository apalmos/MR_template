## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls())


## ----include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(data.table)
library(tidyverse)
library(vroom)
library(rlist)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set up the directories for which scripts need be created
dirs <- list.dirs(recursive = FALSE)
elements_2_remove <- c("./.git", "./scripts")
dirs = dirs[!(dirs %in% elements_2_remove)]

n=1

#slice decides by how many GWASs each script set will be split by; for example, if there are 600 GWASs and slice is set to 150, 4 different script sets will be generated
slice=150

#this loop screates all scripts, for each folder directory
for (j in dirs){
  all_prots <- vroom(paste0(dirs[n],"/full_list"),col_names = FALSE)
  repn <- round(nrow(all_prots)/slice)
  splitted <- split(all_prots,rep(1:paste0(repn),each=paste0(slice)))

  #function to remove any empty lists
  splitted <- list.clean(splitted, function(x) length(x) == 0L, TRUE)
  n_split <- length(splitted)
  sep <- c("'")

  for (i in 1:n_split){

    #here we write the array, according to the slice vector
    split_list <- as.data.frame(splitted[i])
    vroom_write(x = split_list, file = paste0(dirs[n],"/list",i,".txt"), col_names = FALSE, delim = ',')
    flag <- paste0("flag",i,".txt")

    #this script makes the initial slurm command for launching the array
    mr <- c("#!/bin/bash",
            "#SBATCH --nodes=2",
            "#SBATCH --mem-per-cpu=18G",
            "#SBATCH -t 48:00:00",
            " ",
            paste0("number=",i),
            " ",
            "#column -t list${number}.txt > temp${number}",
            "#mv temp${number} list${number}.txt",
            " ",
            "while IFS=$',' read -r -a myArray",
            "do",
            " ",
            "echo ${myArray[0]}",
            "echo ${myArray[1]}",
            " ",
            paste0(" sh mass_mr",i,".sh ${myArray[0]} ${myArray[1]}"),
            " ",
            paste0("done < list",i,".txt"))

    dirs_clean <- dirs
    dirs_clean <- gsub("\\./","",dirs_clean)
    dirs_clean <- gsub("\\_mr","",dirs_clean)

    writeLines(mr, paste0(dirs[n],"/MR",dirs_clean[n],i,".sh"))

    #this script does a little bit of cleaning of the GWASs and creates marker_name files corresponding to the GWAS being analysed. This makes future analyses easier as the protein name and code (for lookup in the metadata) will be available
    clean <- c("#!/bin/bash",
            " ",
            paste0("number=",i),
            "name=$1",
            "original=$2",
            " ",
            paste0("echo 'running cleaning!'"),
            paste0("cp /scratch/prj/gwas_sumstats/cleaned/blood_biomarkers/${original}.gz ./"),
            "gunzip ${original}.gz",
            "Rscript ../scripts/format.R ${original}",
            paste0("echo ''${name} ${original}'' > marker${number}.txt"),
            "echo ''$original'' > marker_name${number}.txt",
            " ",
            #this script runs GSMR. The settings can be changed according to user needs. See the MR_template is any of the below dependencies are missing
            "../../gcta/gcta --bfile /scratch/prj/ukbiobank/usr/alish/1KG_Phase3.WG.CLEANED.EUR_MAF001 --gsmr-file marker${number}.txt target.txt --gsmr-direction 2 --effect-plot --ref-ld-chr /scratch/prj/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ --w-ld-chr /scratch/prj/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ --out ./output/${original} --gwas-thresh 5e-8 --clump-r2 0.05 --heidi-thresh 0.01 --gsmr-snp-min 1 --gsmr-ld-fdr 0.05 --thread-num 4 --diff-freq 0.8",
            " ",
            "rm ${original}"
    )

    writeLines(clean, paste0(dirs[n],"/mass_mr",i,".sh"))

  }

  n=n+1
}
