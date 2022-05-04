#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=9G
#SBATCH -t 48:00:00

number=2

column -t list${number}.txt > temp${number}
mv temp${number} list${number}.txt

while IFS=$'\t' read -r -a myArray
do

  trimmedfile="$(echo -e "${myArray[1]}" | tr -d '[:space:]')"


  sh mass_mr2.sh $trimmedfile ${myArray[0]}


done < list2.txt
