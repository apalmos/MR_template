## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls())


## ----setup, include=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
wd <- getwd()
setwd(wd)


## ----include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(data.table)
library(jtools)
library(knitr)
library(broom)
library(sandwich)
library(tidyverse)
library(ggplot2)
library(sgof)



## ----echo=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

make_list <- function(study, dir){

  current_dir <- dir
  setwd(paste0(current_dir,"/",study,"_mr/output/"))

  list <- list.files(pattern = "*.gsmr")
  mr <- lapply(list, read.delim)
  bind <- do.call(rbind.data.frame, mr)
  bind$file_name = rep(list, each =2)
  n_lists <- list.files(path = paste0(current_dir,"/",study,"_mr/"), pattern = "^list")

  worked = data.frame()
  worked <- unique(bind$file_name)
  worked = data.frame(worked)
  worked$worked <-   gsub("\\..*","",worked$worked)

  for (i in n_lists){

    list <- read.table(paste0(current_dir,"/",study,"_mr/",i), sep = ",")
    names(list)[2] <- "worked"
    worked_list <- setdiff(list$worked, worked$worked)
    worked_list = data.frame(worked_list)
    names(worked_list)[1] <- "worked"
    re_do <- merge(worked_list, list)
    re_do <- re_do %>%
      select(V1, worked)

    write.table(x = re_do, file = paste0(current_dir,"/",study,"_mr/",i), quote = FALSE, row.names = FALSE, col.names = FALSE, sep = ",")
    print(paste0("from ", study,"_",i,": ", nrow(re_do)," to go"))

  }

  setwd(dir)

}



## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

make_list(study = "breth", dir = wd)
make_list(study = "deco", dir = wd)
make_list(study = "enroth", dir = wd)
make_list(study = "folk", dir = wd)
make_list(study = "hill", dir = wd)
make_list(study = "hogl", dir = wd)
make_list(study = "infl", dir = wd)
make_list(study = "scal", dir = wd)
make_list(study = "sliz", dir = wd)
make_list(study = "suhr", dir = wd)
make_list(study = "sun", dir = wd)
make_list(study = "wood", dir = wd)
