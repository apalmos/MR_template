name=$1
zcat /scratch/prj/gwas_sumstats/original/${name}.gz|gawk -F"\t" -v c1="SNP" -v c2="A1" 'NR==1{for(i=1;i<=NF;i++){ix[$i]=i}}NR>1{print $ix[c1],$ix[c2]}' > /scratch//prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_A1
awk '{print $1}' /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_A1 > /scratch/prj/gwas_sumstats/scripts/plinkstuff_for_cojo/${name}_SNP
mkdir /scratch/prj/gwas_sumstats/scripts/computed_frequencies/${name}
for i in `seq 1 22` X; do sbatch -p cpu /scratch/prj/gwas_sumstats/scripts/submit_freq_2.sh ${name} ${i}; done
