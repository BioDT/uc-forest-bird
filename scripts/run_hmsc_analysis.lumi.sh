#!/bin/bash -l
#SBATCH -J hmsc_analysis
#SBATCH -o run_hmsc_analysis_%j.out
#SBATCH -p small
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH -t 0:30:00

export OMP_NUM_THREADS=1
SIF="$PWD/forest-bird_0.3.0.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"
singularity run "$SIF" "analysis/species_richness.R"
