#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o run_landis_%j.out
#SBATCH -p small
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH -t 24:00:00

ROOT_DIR="$1"
if [ -z "$ROOT_DIR" ]; then echo "set directory"; exit 1; fi
CLIMATE="$2"
if [ -z "$CLIMATE" ]; then echo "set climate scenario"; exit 1; fi
HARVEST="$3"
if [ -z "$HARVEST" ]; then echo "set harvest scenario"; exit 1; fi

LANDIS_TEMPLATE_DIR="$ROOT_DIR/landis_template"
SCENARIOS_DIR="$ROOT_DIR/scenarios"
LANDIS_DIR="$ROOT_DIR/run_${SLURM_JOB_ID}/${CLIMATE}_${HARVEST}"
SIF="$PWD/landis_0.3.1.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"

time0=$(date +%s.%N)

# Create new run directory
mkdir -p "$LANDIS_DIR"
cp -p $LANDIS_TEMPLATE_DIR/* $LANDIS_DIR/
cp "$SCENARIOS_DIR/climate_$CLIMATE.txt" $LANDIS_DIR/climate.txt
cp "$SCENARIOS_DIR/biomass_harvest_$HARVEST.txt" $LANDIS_DIR/biomass-harvest.txt
time1=$(date +%s.%N)

# Execute landis
cd "$LANDIS_DIR"
singularity run "$SIF" scenario.txt 2>&1 > out.txt
time2=$(date +%s.%N)

time=$(echo "$time2 - $time0" | bc)
echo "Runtime $time s"

