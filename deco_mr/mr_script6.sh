#!/bin/bash
#SBATCH -c 4
#SBATCH --mem-per-cpu=9G

number=6

code=`cat marker_name${number}.txt`

export MKL_NUM_THREADS=8
export NUMEXPR_NUM_THREADS=8
export OMP_NUM_THREADS=8

/scratch/groups/ukbiobank/usr/alish/gcta/gcta \
--bfile \
/scratch/groups/ukbiobank/usr/alish/Project1_meta/1KG_Phase3.WG.CLEANED.EUR_MAF001 \
--gsmr-file \
marker${number}.txt \
target.txt \
--gsmr-direction 2 \
--effect-plot \
--ref-ld-chr /scratch/groups/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ \
--w-ld-chr /scratch/groups/ukbiobank/KCL_Data/Software/eur_w_ld_chr_for_mtcojo/ \
--out ./output/${code} \
--gwas-thresh 5e-6 \
--clump-r2 0.05 \
--heidi-thresh 0.01 \
--gsmr-snp-min 1 \
--gsmr-ld-fdr 0.05 \
--thread-num 4 \
--diff-freq 0.8

echo 'check' > flag${number}.txt

rm ${code}
