#!/bin/bash
#SBATCH --job-name=SNPs_SW
#SBATCH --partition=regular
#SBATCH --nodes=1
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G 
#SBATCH --output=SNPS_SW-%j.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s.a.gonzalez.mollinedo@rug.nl

src=$1
module load PLINK/1.9

plink --bfile [imputed_SNPs] --allow-extra-chr --homozyg --geno 0.05 --homozyg-density 200 --homozyg-gap 300 --homozyg-het 2 --homozyg-kb 1000 --homozyg-snp 50 --homozyg-window-het 2 --homozyg-window-missing 2 --homozyg-window-snp 50 --mind