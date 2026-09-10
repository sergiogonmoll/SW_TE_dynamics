#!/bin/bash
#SBATCH --job-name=BWA_align
#SBATCH --partition=regular
#SBATCH --cpus-per-task=6
#SBATCH --time=150:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=s.a.gonzalez.mollinedo@rug.nl

module load BWA
module load SAMtools

mkdir /scratch/p309374/SW_genomics/Aligned_mt/
mkdir /scratch/p309374/SW_genomics/Clean_aligned_mt/
for f in /scratch/p309374/SW_genomics/TE_samples/*_trimmed_paired_R1.fastq.gz;
do 		FBASE=$(basename $f)
        BASE=${FBASE%_trimmed_paired_R1.fastq.gz}
        bwa mem -t 10 \
		/scratch/p309374/Ref_genome/Mitochondria_reed_warbler.fasta \
		/scratch/p309374/SW_genomics/TE_samples/${BASE}_trimmed_paired_R1.fastq.gz| \
		samtools sort -o /scratch/p309374/SW_genomics/Aligned_mt/${BASE}_aligned_mt.bam
done

for f in /scratch/p309374/SW_genomics/TE_samples/*_trimmed_paired_R1.fastq.gz;
do 		FBASE=$(basename $f)
        BASE=${FBASE%_trimmed_paired_R1.fastq.gz}
        samtools bam2fq -f 4 -@ 10 /scratch/p309374/SW_genomics/Aligned_mt/${BASE}_aligned_mt.bam > /scratch/p309374/SW_genomics/Clean_aligned_mt/${BASE}no_mt.fastq
done
