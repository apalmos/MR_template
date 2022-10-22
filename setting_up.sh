#!/bin/bash -l

gwas=$1
name=$2
dir=$PWD

#create a target
echo ${dir}/${name} ${gwas} > target.txt

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
