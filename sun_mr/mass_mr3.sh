#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

original=$1
name=$2
code=$3

cp /scratch/groups/ukbiobank/sumstats/cleaned/blood_biomarkers/${original}.gz ./
gunzip ${original}.gz
awk '{print $1, $4, $5, $10, $7, $8, $6, $9}' ${original} > temp3
mv temp3 ${original}
awk 'NF==8{print}{}' ${original} > temp3
mv temp3 ${original}
echo ''${name} ${original}'' > marker3.txt
echo ''$original'' > marker_name3.txt
sbatch -p brc mr_script3.sh

while [ ! -f "flag3.txt" ]
do
    sleep 30s
done

rm flag.txt

sleep 5m
