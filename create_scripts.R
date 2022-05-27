## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls())


## ----include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(data.table)
library(tidyverse)
library(vroom)


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dirs <- list.dirs(recursive = FALSE)
elements_2_remove <- c("./.git", "./scripts")
dirs = dirs[!(dirs %in% elements_2_remove)]

n=1
slice=150

for (j in dirs){
  all_prots <- vroom(paste0(dirs[n],"/full_list"),col_names = FALSE)
  repn <- round(nrow(all_prots)/slice)
  splitted <- split(all_prots,rep(1:paste0(repn),each=paste0(slice)))
  n_split <- length(splitted)
  sep <- c("'")
  for (i in 1:n_split){

    split_list <- as.data.frame(splitted[i])
    vroom_write(x = split_list, file = paste0(dirs[n],"/list",i,".txt"), col_names = FALSE, delim = ',')
    flag <- paste0("flag",i,".txt")

    mr <- c("#!/bin/bash",
            "#SBATCH --nodes=8",
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

    writeLines(mr, paste0(dirs[n],"/MR",i,".sh"), )


    clean <- c("#!/bin/bash",
            " ",
            paste0("number=",i),
            "name=$1",
            "original=$2",
            " ",
            paste0("echo 'running cleaning!'"),
            paste0("cp /scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/${original}.gz ./"),
            "gunzip ${original}",
            "Rscript ../scripts/format.R ${original}",
            paste0("echo ''${name} ${original}'' > marker${number}.txt"),
            "echo ''$original'' > marker_name${number}.txt",
            "sbatch -p brc mr_script${number}.sh",
            " ",
            paste0("while [ ! -f ",flag," ]"),
            "do",
            "    sleep 30s",
            "done",
            "rm flag${number}.txt",
            "sleep 30s"
    )

    writeLines(clean, paste0(dirs[n],"/mass_mr",i,".sh"))

    MR <- c("#!/bin/bash",
            "#SBATCH --nodes=8",
            "#SBATCH --mem-per-cpu=18G",
            "#SBATCH -t 48:00:00",
            " ",
            paste0("number=",i),
            " ",
            "code=`cat marker_name${number}.txt`",
            " ",
            "/scratch/groups/ukbiobank/usr/alish/gcta/gcta --bfile /scratch/groups/ukbiobank/usr/alish/1KG_Phase3.WG.CLEANED.EUR_MAF001 --gsmr-file marker${number}.txt target.txt --gsmr-direction 2 --effect-plot --ref-ld-chr /scratch/groups/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ --w-ld-chr /scratch/groups/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ --out ./output/${code} --gwas-thresh 5e-8 --clump-r2 0.05 --heidi-thresh 0.01 --gsmr-snp-min 1 --gsmr-ld-fdr 0.05 --thread-num 4 --diff-freq 0.8",
            " ",
            "echo 'check' > flag${number}.txt",
            " ",
            "rm ${code}"
            )

    writeLines(MR, paste0(dirs[n],"/mr_script",i,".sh"))

  }

  n=n+1
}