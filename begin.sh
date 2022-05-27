#!/bin/bash -l

#begin all analyses
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
