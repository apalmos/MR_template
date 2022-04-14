#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

original=$1
code=$2

cp /scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/${original}.gz ./
gunzip ${original}.gz 
awk '{print $1, $4, $5, $6, $8, $9, $7, $10}' ${original} > temp 
mv temp ${original}
echo ''${code} ${original}'' > marker.txt
echo ''$original'' > marker_name.txt
sbatch -p brc mr_script.sh

while [ ! -f "flag.txt" ]
do
    sleep 30s
done

rm flag.txt

sleep 5m