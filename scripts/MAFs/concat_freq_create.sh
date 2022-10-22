#!/bin/bash -l
#SBATCH -c 8
#SBATCH --mem-per-cpu=9G

name=$1
if [ -f /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}.frequence ]; then rm /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}.frequence; fi
for i in `seq 1 22` X; do cat /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}_freq_withA1_${i}.frq >> /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}.frequence; done
