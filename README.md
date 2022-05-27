# MR_template
Template for running PWMR on Rosalind

## Copy entire repository into your desired folder
git clone https://github.com/apalmos/MR_template

## Copy your GWAS into the parent directory
```
cp path_to_GWAS ./
```

# Automated script creator
# This script will generate all bash scripts needed to run these analyses in batches of 150. This is optimal given the thousands of GWAS files that need to be processed. Check one or two folders to make sure the bash scrips were created correctly
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

## Once you reach the 48h limit, you need to make new input arrays. Do this by running:
```
bash ./re_make_input.R
```

This will also show you how many files still need to be run.

## Then activate all bash jobs again by running:
```
bash begin.sh
```
