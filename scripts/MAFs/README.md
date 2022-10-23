### Getting MAF from the 1KG reference panel:
### NOTE: Your GWAS must have 'SNP' and 'A1' headers
### NOTE: Your GWAS must be located in the '/scratch/prj/gwas_sumstats/original' folder:

```
cd /scratch/prj/gwas_sumstats/scripts
```

## Run:

```
runplinkstuff_create.sh NAMEOFGWAS

```
for example: runplinkstuff_create.sh MDD01

## Once the script has finished running, move into the directory with the computed frequencies:

```
cd /scratch/prj/gwas_sumstats/scripts/computed_frequencies
```

## Run the script to concatenate all the chromosomes:

```
concat_freq_create.sh NAMEOFGWAS
```
for example concat_freq_create.sh MDD01

Once this is done, you will have to manually merge the newly created MAFs with your GWAS, based on SNPs (RSid)
