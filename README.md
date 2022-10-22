# Proteome-wide Mendelian randomization (& beyond!)
Template for running PWMR on CREATE. We have downloaded thousands of blood protein GWASs, QC'd them and stored them in a repo. If you wish to have access to the repo, please e-mail me: alishpalmos@gmail.com

If you already have access to the repo, follow the code below to run PWMR on all proteins and your trait of choice.

## Useful info
We have all metadata available, please e-mail me for more information

Provided you have downloaded all the dependencies, you will just need your input GWAS (outcome of interest) to run this pipeline. Currently, it runs bi-directional GSMR at the highest GWAS threshold, but these setting can be changed in the create_script.R script.

Note that the reason for automating script creation is to distribute computational requirements across many runs. Running large jobs in parallel proved to take too long.

## Copy entire repository into your desired folder
```
git clone https://github.com/apalmos/MR_template
```

You must install the latest version of GCTA, to make it work with the pipeline install it one directory higher than MR_template:

```
wget https://yanglab.westlake.edu.cn/software/gcta/bin/gcta_v1.94.0Beta_linux_kernel_3_x86_64.zip
unzip gcta_v1.94.0Beta_linux_kernel_3_x86_64.zip
```

# change name to suit the script generator:
```
mv gcta_v1.94.0Beta_linux_kernel_3_x86_64 gcta
```

# LD references
To run this script you will need the 1KG reference panel.

You can download the eur_w_ld_chr here:

```
https://alkesgroup.broadinstitute.org/LDSCORE
```

You also need to download the 1KG whole genome data here:

```
wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eur.zip
unzip g1000_eur.zip
```

Note that the the automated scripts currently run with all files on CREATE HPC, where the 1KG WG data has been cleaned. You may want to consider your own QC if downloading the data above. You would also need to change these commands in the create_scripts.R file to suit the newly downloaded files (if you are on CREATE, you don't need to do anything):

```
/scratch/prj/gwas_sumstats/resources/gcta/gcta
--bfile /scratch/prj/gwas_sumstats/resources/1KG_Phase3.WG.CLEANED.EUR_MAF001
--gsmr-file marker${number}.txt target.txt
--gsmr-direction 2
--effect-plot
--ref-ld-chr /scratch/prj/gwas_sumstats/resources/eur_w_ld_chr_for_mtcojo/
--w-ld-chr /scratch/prj/gwas_sumstats/resources/eur_w_ld_chr_for_mtcojo/
```

## Copy your GWAS into the correct directory

If you are using CREATE and have access to the GWAS sumstats catalogue, then you need to create a folder with the name of your GWAS in the /inflame directory. This is where the analyses will be carried out.

Note your GWAS must have the following headers:

SNP / A1 / A2 / MAF / BETA / SE / P / N

For inferring MAFs from the 1KG dataset, please e-mail me.

In your GWAS folder:

```
cp path_to_GWAS ./
```

# Automated script creator
This script will generate all bash scripts needed to run these analyses in batches of 150. This is optimal given the thousands of GWAS files that need to be processed. Check one or two folders to make sure the bash scrips were created correctly

Note: I highly recommend setting up a conda environment with the necessary R packages & the latest version of R (mainly tidyverse, dplyr, data.table). If you already have these in your base directory, please ignore.

```
Rscript create_scripts.R
```

## Copy your GWAS into the parent directory (MR_template) & run
```
bash setting_up.sh GWAS_filename You_name_for_GWAS
```

## Start all jobs by submitting
```
bash begin.sh
```
Note: change the MR scripts according to your needs

## Once you reach the 48h limit, you need to make new input arrays. Do this by running:
```
Rscript ./re_make_input.R
```

This will also show you how many files still need to be run.

## Then activate all bash jobs again by running:
```
bash begin.sh
```

# Sensitivity analsyes

## Once all the analyses are done, you can create an excel file with all output files.

Note that phenotype_name should be replaced with the same phenotype as the one used in GWAS naming above. In addition, the p_val should be set at the desired p-value (corrected) for creating the final figure
```
Rscript scripts/main_GSMR_parsing.R phenotype_name p_val
```
## Once the main results are extracted, you may want to run sensitivity analyses using the TwoSampleMR package.

Running these, parsing the results and creating figures can be carried out with one command. Note that the name of the phenotype should be the same as the one used in GWAS naming above. Also the column headers needs to be as described above.
```
Rscript scripts/sensitivity_analyses.R phenotype_name
```

The above script will create output folders containing all SNP data + figure for each protein from GSMR results & all SNP data + figure for each protein from TwoSampleMR using MR Egger, Weighted Median, Inverse variance weighted, Simple mode & Weighted mode methods.
