#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

code=$1
original=$2
name=$3
number=3

cp /scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/${code}.gz ./
gunzip ${code}.gz
awk '{print $3, $4, $5, $10, $6, $8, $7, $9}' ${code} > temp${number}
mv temp${number} ${code}
awk '/^SNP|^r[s]/' ${code} > temp${number}
mv temp${number} ${code}
awk '!seen[$1]++' ${code} > temp${number}
mv temp${number} ${code}
awk 'NF==8' ${code} > temp${number}
mv temp${number} ${code}
echo ''${name} ${code}'' > marker${number}.txt
echo ''$code'' > marker_name${number}.txt
sbatch -p brc mr_script${number}.sh

while [ ! -f "flag${number}.txt" ]
do
    sleep 30s
done

rm flag${number}.txt
rm ${original}

sleep 5m