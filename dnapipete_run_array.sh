#!/bin/bash
#SBATCH --time=45:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --job-name=dnapipete
#SBATCH --output=dnapipete_run-%a.log
#SBATCH --mem-per-cpu=10GB
#SBATCH --partition=regular

input_path=$1

mkdir /mnt/output/
cd /opt/dnaPipeTE/
python3 dnaPipeTE.py -input /mnt/Samples/${input_path} -output /tmp/output_${input_path} -RM_lib /mnt/ZF_reduced.fa -genome_size 960011837 -genome_coverage 0.1 -sample_number 3 -RM_t 0.2 -cpu 10

sed 's/^/'${input_path}' /' /tmp/output_${input_path}/reads_per_component_and_annotation > /tmp/output_${input_path}/reads_per_component_and_annotation_${input_path}

cp /tmp/output_${input_path}/reads_per_component_and_annotation_${input_path} /mnt/output/
