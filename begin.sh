#!/bin/bash -l

#begin all analyses
cd ./breth_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run breth'

cd ../deco_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run deco'

cd ../enroth_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run enroth'

cd ../folk_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run folk'

cd ../hill_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run hill'

cd ../hogl_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run hogl'

cd ../infl_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run infl'

cd ../scal_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run scal'

cd ../sliz_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run sliz'

cd ../suhr_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run suhr'

cd ../sun_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run sun'

cd ../wood_mr
for f in MR*; do
  sbatch -p cpu "$f"
done
echo 'run wood'
