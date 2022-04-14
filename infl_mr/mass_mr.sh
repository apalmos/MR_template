#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

original=$1
name=$2
code=$3

cp /scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/${code}.gz ./
gunzip ${code}.gz
awk '!seen[$1]++' ${code} > temp
mv temp ${code}
echo ''${name} ${code}'' > marker.txt
echo ''$code'' > marker_name.txt
sbatch -p brc mr_script.sh

while [ ! -f "flag.txt" ]
do
    sleep 30s
done

rm flag.txt

sleep 5m