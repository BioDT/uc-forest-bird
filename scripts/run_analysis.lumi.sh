#!/bin/bash -l
#SBATCH -J analysis
#SBATCH -o analysis_%j.out
#SBATCH -p small
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH -t 00:30:00
#SBATCH --array=0-5

analysis_scripts=(\
    visualize_based_on_total_cohorts.R \
    visualize_deadwood.R \
    visualize_harvested_biomass.R \
)

RUN_DIR="$1"
if [ -z "$RUN_DIR" ]; then echo "set run directory"; exit 1; fi
if [ ! -d "$RUN_DIR" ]; then echo "directory missing: $RUN_DIR"; exit 1; fi

RESULTS_DIR="${2:-results}"
mkdir -p "$RESULTS_DIR"

script=${3:-analysis/${analysis_scripts[$SLURM_ARRAY_TASK_ID]}}

SIF="$PWD/forest-bird_0.3.0.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"
echo $script
singularity run "$SIF" "$script" "$RUN_DIR" "$RESULTS_DIR"

