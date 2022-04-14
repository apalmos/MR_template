#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

name=$1
original=$2

cp /scratch/groups/gwas_sumstats/cleaned/blood_biomarkers/${original}.gz ./
gunzip ${original}
echo ''${name} ${original}'' > marker.txt
echo ''$original'' > marker_name.txt
sbatch -p brc mr_script.sh

while [ ! -f "flag.txt" ]
do
    sleep 30s
done

rm flag.txt

sleep 5m