#!/bin/bash -l
#SBATCH -c 8
#SBATCH --mem-per-cpu=9G

name=$1
i=$2
/scratch/prj/gwas_sumstats/resources/plink --bfile /scratch/prj/ukbiobank/KCL_Data/Resources/1KG/1KG_Phase3/1KG_Phase3.chr${i}.CLEANED.EUR --extract /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_SNP --a1-allele /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_A1 2 1 --freq --out /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}_freq_withA1_${i}
