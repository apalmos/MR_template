# MR_template
Template for running PWMR on Rosalind

## Copy entire repository into your desired folder
git clone https://github.com/apalmos/MR_template

You must install the latest version of GCTA, to make it work with the pipeline install it one directory higher than MR_template:

```
wget https://yanglab.westlake.edu.cn/software/gcta/bin/gcta_v1.94.0Beta_linux_kernel_3_x86_64.zip
unzip gcta_v1.94.0Beta_linux_kernel_3_x86_64.zip

# change name to suit the script generator:
mv gcta_v1.94.0Beta_linux_kernel_3_x86_64 gcta
```
# LD references
To run this script you will need the 1KG reference panel.

You can download the eur_w_ld_chr here: https://alkesgroup.broadinstitute.org/LDSCORE
You also need to download the 1KG whole genome data here:

```
wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eur.zip
unzip g1000_eur.zip
```
Note that the the automated scripts currently run with all files on Rosalind HPC, where the 1KG WG data has been cleaned. You may want to consider your own QC if downloading the data above. You would also need to change these commands in the create_scripts.R file to suit the newly downloaded files (if you are on Rosalind, you don't need to do anything):

```
"../gcta/gcta --bfile /scratch/groups/ukbiobank/usr/alish/1KG_Phase3.WG.CLEANED.EUR_MAF001 --gsmr-file marker${number}.txt target.txt --gsmr-direction 2 --effect-plot --ref-ld-chr /scratch/groups/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ --w-ld-chr /scratch/groups/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ 
```

## Copy your GWAS into the parent directory
Note your GWAS must have the following headers:

SNP / A1 / A2 / MAF / BETA / SE / P / N

For inferring MAFs from the 1KG dataset, please e-mail me (alishpalmos@gmail.com)

```
cp path_to_GWAS ./
```

# Automated script creator
This script will generate all bash scripts needed to run these analyses in batches of 150. This is optimal given the thousands of GWAS files that need to be processed. Check one or two folders to make sure the bash scrips were created correctly
```
Rscript create_scripts.R
```

## Copy your GWAS into the parent direcotry (MR_template) & run
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
bash ./re_make_input.R
```

This will also show you how many files still need to be run.

## Then activate all bash jobs again by running:
```
bash begin.sh
```
## Soon: analysis scripts for parsing all the data will be automated
