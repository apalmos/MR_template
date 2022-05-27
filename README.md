# Proteome-wide Mendelian randomization (& beyond!)
Template for running PWMR on Rosalind. We have downloaded thousands of blood protein GWASs, QC'd them and stored them in a repo. If you wish to have access to the repo, please e-mail me: alishpalmos@gmail.com

Studies included:

https://pubmed.ncbi.nlm.nih.gov/28240269/
https://pubmed.ncbi.nlm.nih.gov/27989323/
https://www.nature.com/articles/s41598-017-10812-1
https://www.nature.com/articles/s41467-018-05512-x
http://dx.plos.org/10.1371/journal.pgen.1006706
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6218410/
https://pubmed.ncbi.nlm.nih.gov/31900758/
https://pubmed.ncbi.nlm.nih.gov/31320639/
https://www.ncbi.nlm.nih.gov/pubmed/?term=31217265
https://pubmed.ncbi.nlm.nih.gov/23696881/
https://pubmed.ncbi.nlm.nih.gov/25147954/
https://pubmed.ncbi.nlm.nih.gov/29875488/
https://pubmed.ncbi.nlm.nih.gov/29875488/
https://www.nature.com/articles/s41598-018-23860-y
https://www.nature.com/articles/s41598-019-53111-7
https://pubmed.ncbi.nlm.nih.gov/26833098/
https://pubmed.ncbi.nlm.nih.gov/22479202/
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7337286/
https://www.nature.com/articles/s42255-020-00287-2#Abs1
https://www.nature.com/articles/s41588-021-00857-4

GWAS catalogue links:

https://www.ebi.ac.uk/gwas/publications/28240269
https://www.ebi.ac.uk/gwas/publications/27989323
https://www.ebi.ac.uk/gwas/publications/28887542
https://www.ebi.ac.uk/gwas/studies/GCST007128
https://www.ebi.ac.uk/gwas/publications/28369058#study_panel
https://www.ebi.ac.uk/gwas/publications/27286809
https://www.ebi.ac.uk/gwas/publications/31900758
https://www.ebi.ac.uk/gwas/publications/31320639
https://www.ebi.ac.uk/gwas/publications/31217265
https://www.ebi.ac.uk/gwas/publications/23696881
https://www.ebi.ac.uk/gwas/publications/25147954
https://www.ebi.ac.uk/gwas/publications/29875488
https://www.ebi.ac.uk/gwas/publications/29875488
https://zenodo.org/record/1629431#.XysKVRMzbOR
https://www.ebi.ac.uk/gwas/publications/31727947
https://www.ebi.ac.uk/gwas/publications/26833098
https://www.ebi.ac.uk/gwas/publications/22479202
https://datashare.is.ed.ac.uk/handle/10283/3649
https://zenodo.org/record/2615265#.YaD2uJDMLOQ
https://www.decode.com/summarydata/

## Useful info
We have all metadata available, please e-mail me for more information

Provided you have downloaded all the dependencies, you will just need your input GWAS (outcome of interest) to run this pipeline. Currently, it runs bi-directional GSMR at the highest GWAS threshold, but these setting can be changed in the create_script.R script.

Note that the reason for automating script creation is to distribute computational requirements across many runs. Running large jobs in parallel proved to take too long.

I will soon add the automated analysis script, which can parse all output & run TwoSampleMR sensitivity analyses, MVMR for any multivariate analyses and MR-BMA, which is a Bayesian algorithm to perform risk factor selection in multivariable MR. I also have additional eQTL and QTLEnrich scripts for identifying target expression with your significant findings - these will also be appended to the pipeline.

## Copy entire repository into your desired folder
```
git clone https://github.com/apalmos/MR_template
```

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

For inferring MAFs from the 1KG dataset, please e-mail me

```
cp path_to_GWAS ./
```

# Automated script creator
This script will generate all bash scripts needed to run these analyses in batches of 150. This is optimal given the thousands of GWAS files that need to be processed. Check one or two folders to make sure the bash scrips were created correctly

Note: I highly recommend setting up a conda environment with the necessary R packages & the latest version of R (mainly tidyverse, dplyr, data.table). If you already have these in your base directory, please ignore.
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
