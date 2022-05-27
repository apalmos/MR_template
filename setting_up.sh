#!/bin/bash -l

gwas=$1
name=$2

#create a target
echo ${name} ${gwas} > target.txt

#copy GWAS into each folder
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

#copy target into each folder
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

#create output folder (in case they're not there already)
mkdir ./breth_mr/output
mkdir ./deco_mr/output
mkdir ./enroth_mr/output
mkdir ./folk_mr/output
mkdir ./hill_mr/output
mkdir ./hogl_mr/output
mkdir ./infl_mr/output
mkdir ./scal_mr/output
mkdir ./sliz_mr/output
mkdir ./suhr_mr/output
mkdir ./sun_mr/output
mkdir ./wood_mr/output
