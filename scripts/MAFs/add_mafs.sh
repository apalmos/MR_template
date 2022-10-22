##########Getting MAF from the 1KG reference panel:
##########NOTE: Your GWAS must have 'SNP' and 'A1' headers
##########NOTE: Your GWAS must be located in the '/scratch/prj/gwas_sumstats/cleaned' folder

cd /scratch/prj/gwas_sumstats/scripts

##########Run:

runplinkstuff_2.sh NAMEOFGWAS_WITHOUT_gz
##########for example: runplinkstuff_2.sh MDD01

name=$1
zcat /scratch/prj/gwas_sumstats/original/${name}.gz|gawk -F"\t" -v c1="SNP" -v c2="A1" 'NR==1{for(i=1;i<=NF;i++){ix[$i]=i}}NR>1{print $ix[c1],$ix[c2]}' > /scratch//prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_A1
awk '{print $1}' /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_A1 > /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_SNP
mkdir /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}
for i in `seq 1 22` X; do sbatch -p cpu /scratch/prj/gwas_sumstats/scripts/submit_freq_2.sh ${name} ${i}; done

######################################################################
##########The above script runs the script below for each chromosome:

submit_freq_2.sh

#!/bin/bash -l
#SBATCH -c 8
#SBATCH --mem-per-cpu=9G

name=$1
i=$2
/scratch/prj/ukbiobank/KCL_Data/Software/plink --bfile /scratch/prj/ukbiobank/KCL_Data/Resources/1KG/1KG_Phase3/1KG_Phase3.chr${i}.CLEANED.EUR --extract /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_SNP --a1-allele /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_A1 2 1 --freq --out /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}_freq_withA1_${i}

######################################################################
##########Once the script has finished running, move into the directory with the computed frequencies:

cd /scratch/prj/gwas_sumstats/scripts/computed_frequencies

##########Run the script to concatenate all the chromosomes:

concat_freq_2.sh NAME_OF_GWAS_without_gz
##concat_freq_2.sh AUD04

#!/bin/bash -l
#SBATCH -c 8
#SBATCH --mem-per-cpu=9G

name=$1
if [ -f /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}.frequence ]; then rm /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}.frequence; fi
for i in `seq 1 22` X; do cat /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}_freq_withA1_${i}.frq >> /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}/${name}.frequence; done

##########Once this is done, you will have to manually merge the newly created MAFs with your GWAS, based on SNPs (RSid)

######################################################################
