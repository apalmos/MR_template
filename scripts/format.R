file <- commandArgs(trailingOnly = TRUE)

  library(data.table)
  library(tidyverse)
  library(vroom)

file = "DECO2894"

df <- vroom(file, col_names = TRUE)

if("SE" %in% colnames(df)){

  df <- df %>%
    select(SNP, A1, A2, MAF, BETA, SE, P, N)

  df <- df[!duplicated(df$SNP), ]


    } else if ("STDERR" %in% colnames(df)){

        df <- df %>%
          select(SNP, A1, A2, MAF, BETA, STDERR, P, N)

        df <- df[!duplicated(df$SNP), ]

    }

vroom_write(x = df, file = file, col_names = TRUE)
