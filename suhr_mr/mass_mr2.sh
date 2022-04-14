#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G

original=$1
name=$2
code=$3

cp /scratch/groups/ukbiobank/sumstats/cleaned/blood_biomarkers/${original}.gz ./
gunzip ${original}.gz
awk '{print $1, $4, $5, $10, $7, $8, $6, $9}' ${original} > temp2
mv temp2 ${original}
awk 'NF==8{print}{}' ${original} > temp2
mv temp2 ${original}
echo ''${name} ${original}'' > marker2.txt
echo ''$original'' > marker_name2.txt
sbatch -p brc mr_script2.sh

while [ ! -f "flag2.txt" ]
do
    sleep 30s
done

rm flag2.txt

sleep 5m