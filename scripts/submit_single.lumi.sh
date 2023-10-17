#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o landis.out
#SBATCH -p small
#SBATCH -n 1
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=1
#SBATCH -t 04:00:00

SIF="$PWD/landis_0.2.1.sif"

pushd LANDIS_run/
date
singularity run  --bind "$PWD" "$SIF" scenario.txt
date
