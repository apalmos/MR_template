#!/bin/bash -l

cd ./breth_mr
sbatch -p brc MR.sh 
cd ../deco_mr
sbatch -p brc MR1.sh 
sbatch -p brc MR2.sh
sbatch -p brc MR3.sh 
sbatch -p brc MR4.sh
sbatch -p brc MR5.sh
sbatch -p brc MR6.sh
sbatch -p brc MR7.sh
sbatch -p brc MR8.sh
sbatch -p brc MR9.sh
sbatch -p brc MR10.sh
cd ../enroth_mr
sbatch -p brc MR.sh
cd ../folk_mr
sbatch -p brc MR.sh
cd ../hill_mr
sbatch -p brc MR.sh
cd ../hogl_mr
sbatch -p brc MR.sh
cd ../infl_mr
sbatch -p brc MR.sh
cd ../scal_mr
sbatch -p brc MR.sh
cd ../sliz_mr
sbatch -p brc MR.sh
cd ../suhr_mr  
sbatch -p brc MR.sh
sbatch -p brc MR2.sh
cd ../sun_mr  
sbatch -p brc MR.sh  
sbatch -p brc MR2.sh   
sbatch -p brc MR3.sh  
sbatch -p brc MR4.sh
cd ../wood_mr
sbatch -p brc MR.sh

