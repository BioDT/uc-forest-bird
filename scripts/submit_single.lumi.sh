#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o run_landis_%j.out
#SBATCH -p small
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1 --mem-per-cpu=8G
#SBATCH -t 24:00:00

LANDIS_TEMPLATE_DIR="$PWD/run_landis_template"
LANDIS_DIR="run_landis_$SLURM_JOB_ID"
SIF="$PWD/landis_0.3.0.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"

time0=$(date +%s.%N)

# Create new run directory
mkdir -p "$LANDIS_DIR"
cp -p $LANDIS_TEMPLATE_DIR/* $LANDIS_DIR/
time1=$(date +%s.%N)

# Execute landis
cd "$LANDIS_DIR"
singularity run "$SIF" scenario.txt
time2=$(date +%s.%N)

time=$(echo "$time2 - $time0" | bc)
echo "Runtime $time s"

