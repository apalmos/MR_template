file <- commandArgs(trailingOnly = TRUE)

  library(data.table)
  library(tidyverse)
  library(vroom)

  df <- read.table(file, header = TRUE)

  df <- df %>%
    select(SNP, A1, A2, MAF, BETA, SE, P, N)

  df <- df[!duplicated(df$SNP), ]

  vroom_write(x = df, file = file, col_names = TRUE)
