# MR_template
Template for running PWMR on Rosalind

## Copy entire repository into your desired folder 

## Create a phenotype file for GSMR:
echo 'name name_of_GWAS' > target.txt

## To copy this into all directories run:
bash ./copy_target.sh

## To copy GWAS file into all directories run: 
bash ./copy_GWAS.sh

## Once you reach the 48h limit, you need to make new input arrays. Do this by running: 
bash ./re_make_input.R 

This will also show you how many files still need to be run. 

I'm still working on optimising the number of arrays, as it's taking a long time to run on the current HPC. 
