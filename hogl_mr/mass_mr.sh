#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

original=$1
name=$2
code=$3

cp /scratch/groups/ukbiobank/sumstats/cleaned/blood_biomarkers/${original}.gz ./
gunzip ${original}.gz
awk '{print $1, $4, $5, $6, $7, $8, $9, $10}' ${original} > temp
mv temp ${original}
awk 'NF==8{print}{}' ${original} > temp
mv temp ${original}
awk '!seen[$1]++' ${original} > temp
mv temp ${original}
echo ''${name} ${original}'' > marker.txt
echo ''$original'' > marker_name.txt
sbatch -p brc mr_script.sh

while [ ! -f "flag.txt" ]
do
    sleep 30s
done

rm flag.txt

sleep 5m