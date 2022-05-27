#!/bin/bash -l

gwas=$1
name=$2

#create a target 
echo '${name} ${gwas}' > target.txt

cp ${gwas} ./breth_mr
cp ${gwas} ./deco_mr
cp ${gwas} ./enroth_mr
cp ${gwas} ./folk_mr
cp ${gwas} ./hill_mr
cp ${gwas} ./hogl_mr
cp ${gwas} ./infl_mr
cp ${gwas} ./scal_mr
cp ${gwas} ./sliz_mr
cp ${gwas} ./suhr_mr
cp ${gwas} ./sun_mr
cp ${gwas} ./wood_mr

cp target.txt ./breth_mr
cp target.txt ./deco_mr
cp target.txt ./enroth_mr
cp target.txt ./folk_mr
cp target.txt ./hill_mr
cp target.txt ./hogl_mr
cp target.txt ./infl_mr
cp target.txt ./scal_mr
cp target.txt ./sliz_mr
cp target.txt ./suhr_mr
cp target.txt ./sun_mr
cp target.txt ./wood_mr

cd ./breth_mr
sbatch -p brc MR*
cd ../deco_mr
sbatch -p brc MR*
cd ../enroth_mr
sbatch -p brc MR*
cd ../folk_mr
sbatch -p brc MR*
cd ../hill_mr
sbatch -p brc MR*
cd ../hogl_mr
sbatch -p brc MR*
cd ../infl_mr
sbatch -p brc MR*
cd ../scal_mr
sbatch -p brc MR*
cd ../sliz_mr
sbatch -p brc MR*
cd ../suhr_mr
sbatch -p brc MR*
cd ../sun_mr
sbatch -p brc MR*
cd ../wood_mr
sbatch -p brc MR*
