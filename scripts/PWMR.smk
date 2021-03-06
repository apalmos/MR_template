##########
# Pipeline Preparation
##########

####
# Download dependencies
####

# Download qctool v2
rule download_qctool2:
  output:
    "resources/software/qctool2/qctool"
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/software/qctool2/; \
     wget --no-check-certificate -O resources/software/qctool2/qctool2.tgz https://www.well.ox.ac.uk/~gav/resources/qctool_v2.0.8-CentOS_Linux7.6.1810-x86_64.tgz; \
     tar -zxvf resources/software/qctool2/qctool2.tgz -C resources/software/qctool2/ --strip-components=1; \
     rm resources/software/qctool2/qctool2.tgz"

# Download impute2_data
rule download_impute2_data:
  output:
    directory("resources/data/impute2/1000GP_Phase3")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/impute2/; \
     wget --no-check-certificate -O resources/data/impute2/1000GP_Phase3.tgz https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz; \
     tar -zxvf resources/data/impute2/1000GP_Phase3.tgz -C resources/data/impute2/; \
     rm resources/data/impute2/1000GP_Phase3.tgz; \
     wget --no-check-certificate -O resources/data/impute2/1000GP_Phase3_chrX.tgz https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3_chrX.tgz; \
     tar -zxvf resources/data/impute2/1000GP_Phase3_chrX.tgz -C resources/data/impute2/1000GP_Phase3/; \
     rm resources/data/impute2/1000GP_Phase3_chrX.tgz"

# Download PLINK. DBSLMM requires the binary to be specified, which is challenging with conda environments. I have tried to avoid this again but no joy. The conda environment may not exist when the snakemake is executed which will cause problems if trying to access the conda environment manually.
rule download_plink:
  output:
    "resources/software/plink/plink"
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/software/plink; \
     wget --no-check-certificate -O resources/software/plink/plink_linux_x86_64_20210606.zip https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20210606.zip; \
     unzip resources/software/plink/plink_linux_x86_64_20210606.zip -d resources/software/plink; \
     rm resources/software/plink/plink_linux_x86_64_20210606.zip"

# Download LDSC
rule download_ldsc:
  output:
    "resources/software/ldsc/ldsc.py"
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "git clone https://github.com/bulik/ldsc.git resources/software/ldsc/"

# Download LDSC reference data
rule dowload_ldsc_ref:
  output:
    directory("resources/data/ldsc_ref/eur_w_ld_chr")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/ldsc_ref; \
     wget --no-check-certificate -O resources/data/ldsc_ref/eur_w_ld_chr.tar.bz2 https://data.broadinstitute.org/alkesgroup/LDSCORE/eur_w_ld_chr.tar.bz2; \
     tar -jxvf resources/data/ldsc_ref/eur_w_ld_chr.tar.bz2 -C resources/data/ldsc_ref/; \
     rm resources/data/ldsc_ref/eur_w_ld_chr.tar.bz2"

# Download hapmap3 snplist
rule download_hm3_snplist:
  output:
    "resources/data/hm3_snplist/w_hm3.snplist"
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/hm3_snplist; \
     wget --no-check-certificate -O resources/data/hm3_snplist/w_hm3.snplist.bz2 https://data.broadinstitute.org/alkesgroup/LDSCORE/w_hm3.snplist.bz2; \
     bunzip2 resources/data/hm3_snplist/w_hm3.snplist.bz2"

# Download DBSLMM
# Specifying old commit as developer has deleted dbslmm binary (accidentally?)
rule download_dbslmm:
  output:
    directory("resources/software/dbslmm/")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "git clone https://github.com/biostat0903/DBSLMM.git {output}; \
     cd {output}; \
     git reset --hard aa6e7ad5b8a7d3b6905556a4007c4a1fa2925b7d; \
     chmod a+x software/dbslmm"

# Download LD block data
rule download_ld_blocks:
  output:
    directory("resources/data/ld_blocks/")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "git clone https://bitbucket.org/nygcresearch/ldetect-data.git {output}"

# install lassosum
rule install_lassosum:
  output:
    touch("resources/software/install_lassosum.done")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "Rscript -e 'remotes::install_github(\"tshmak/lassosum\")'"

# install bigsnpr
rule install_bigsnpr:
  output:
    touch("resources/software/install_bigsnpr.done")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "Rscript -e 'remotes::install_github(\"privefl/bigsnpr\")'"

# install ggchicklet
rule install_ggchicklet:
  output:
    touch("resources/software/install_ggchicklet.done")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "Rscript -e 'remotes::install_github(\"hrbrmstr/ggchicklet\")'"

# Install Rpackages manually
rule install_manual_Rpackages:
  input:
    rules.install_ggchicklet.output,
    rules.install_bigsnpr.output,
    rules.install_lassosum.output

# Download liftover
rule install_liftover:
  output:
    touch("resources/software/install_liftover.done")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/software/liftover/; wget --no-check-certificate -O resources/software/liftover/liftover https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver"

# Download liftover track
rule download_liftover_track:
  output:
    touch("resources/software/download_liftover_track.done")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/liftover/; wget --no-check-certificate -O resources/data/liftover/hg19ToHg38.over.chain.gz ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz"

# Download PRScs reference
rule download_prscs_ref_1kg_eur:
  output:
    "resources/data/prscs_ref/ldblk_1kg_eur/ldblk_1kg_chr1.hdf5"
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/prscs_ref; \
     wget --no-check-certificate -O resources/data/prscs_ref/ldblk_1kg_eur.tar.gz https://www.dropbox.com/s/mt6var0z96vb6fv/ldblk_1kg_eur.tar.gz?dl=0; \
     tar -zxvf resources/data/prscs_ref/ldblk_1kg_eur.tar.gz -C resources/data/prscs_ref/; \
     rm resources/data/prscs_ref/ldblk_1kg_eur.tar.gz"

# Download PRScs software
rule download_prscs_software:
  output:
    directory("resources/software/prscs/")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "git clone https://github.com/getian107/PRScs.git {output}"

# Download gctb reference
rule download_gctb_ref:
  output:
    directory("resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/gctb_ref; wget --no-check-certificate -O resources/data/gctb_ref/ukbEURu_hm3_sparse.zip https://zenodo.org/record/3350914/files/ukbEURu_hm3_sparse.zip?download=1; unzip resources/data/gctb_ref/ukbEURu_hm3_sparse.zip -d resources/data/gctb_ref; for chr in $(seq 1 22);do mv resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_chr${{chr}}_v3_50k.ldm.sparse.bin resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_v3_50k_chr${{chr}}.ldm.sparse.bin; mv resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_chr${{chr}}_v3_50k.ldm.sparse.info resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_v3_50k_chr${{chr}}.ldm.sparse.info; mv resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_chr${{chr}}_v3_50k_sparse.log resources/data/gctb_ref/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_v3_50k_sparse_chr${{chr}}.log; done; rm resources/data/gctb_ref/ukbEURu_hm3_sparse.zip"

# Download GCTB
rule download_gctb_software:
  output:
    "resources/software/gctb/gctb_2.03beta_Linux/gctb"
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/software/gctb; \
     wget --no-check-certificate -O resources/software/gctb/gctb_2.03beta_Linux.zip https://cnsgenomics.com/software/gctb/download/gctb_2.03beta_Linux.zip; \
     unzip resources/software/gctb/gctb_2.03beta_Linux.zip -d resources/software/gctb; \
     rm resources/software/gctb/gctb_2.03beta_Linux.zip"

# Download LDpred2 reference
rule download_ldpred2_ref:
  output:
    directory("resources/data/ldpred2_ref")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/ldpred2_ref; wget --no-check-certificate -O resources/data/ldpred2_ref/download.zip https://figshare.com/ndownloader/articles/19213299/versions/1; unzip resources/data/ldpred2_ref/download.zip -d resources/data/ldpred2_ref/; rm resources/data/ldpred2_ref/download.zip"

# Download LDAK
rule download_ldak:
  output:
    directory("resources/software/ldak")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/software/ldak; wget --no-check-certificate -O resources/software/ldak/ldak5.1.linux_.zip https://dougspeed.com/wp-content/uploads/ldak5.1.linux_.zip; unzip resources/software/ldak/ldak5.1.linux_.zip -d resources/software/ldak/; rm resources/software/ldak/ldak5.1.linux_.zip"

# Download LDAK map data
rule download_ldak_map:
  output:
    directory("resources/data/ldak_map")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/ldak_map; wget --no-check-certificate -O resources/data/ldak_map/genetic_map_b37.zip https://www.dropbox.com/s/slchsd0uyd4hii8/genetic_map_b37.zip; unzip resources/data/ldak_map/genetic_map_b37.zip -d resources/data/ldak_map/; rm resources/data/ldak_map/genetic_map_b37.zip"

# Download LDAK bld snp annotations
rule download_ldak_bld:
  output:
    directory("resources/data/ldak_bld")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/ldak_bld; wget --no-check-certificate -O resources/data/ldak_bld/bld.zip https://genetics.ghpc.au.dk/doug/bld.zip; unzip resources/data/ldak_bld/bld.zip -d resources/data/ldak_bld/; rm resources/data/ldak_bld/bld.zip"

# Download LDAK high ld regions file
rule download_ldak_highld:
  output:
    directory("resources/data/ldak_highld")
  conda:
    "../envs/GenoPredPipe.yaml"
  shell:
    "mkdir -p resources/data/ldak_highld; wget --no-check-certificate -O resources/data/ldak_highld/highld.txt https://dougspeed.com/wp-content/uploads/highld.txt"
