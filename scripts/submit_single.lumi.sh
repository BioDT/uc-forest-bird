#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o run_landis_%j.out
#SBATCH -p small
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH -t 24:00:00

# Timing
time0=$(date +%s.%N)

# Parse command-line arguments
ROOT_DIR="$1"
if [ -z "$ROOT_DIR" ]; then echo "set directory"; exit 1; fi
CLIMATE="$2"
if [ -z "$CLIMATE" ]; then echo "set climate scenario"; exit 1; fi
HARVEST="$3"
if [ -z "$HARVEST" ]; then echo "set harvest scenario"; exit 1; fi

# Check input directories
LANDIS_TEMPLATE_DIR="$ROOT_DIR/landis_template"
if [ ! -d "$LANDIS_TEMPLATE_DIR" ]; then echo "directory missing: $LANDIS_TEMPLATE_DIR"; exit 1; fi
SCENARIOS_DIR="$ROOT_DIR/scenarios"
if [ ! -d "$SCENARIOS_DIR" ]; then echo "directory missing: $SCENARIOS_DIR"; exit 1; fi

# Create new run directory
LANDIS_DIR="$ROOT_DIR/run_${SLURM_JOB_ID}/${CLIMATE}_${HARVEST}"
mkdir -p "$LANDIS_DIR"
cp -p $LANDIS_TEMPLATE_DIR/* $LANDIS_DIR/
cp "$SCENARIOS_DIR/climate_$CLIMATE.txt" $LANDIS_DIR/climate.txt
cp "$SCENARIOS_DIR/biomass_harvest_$HARVEST.txt" $LANDIS_DIR/biomass-harvest.txt

# Timing
time1=$(date +%s.%N)

# Execute landis
SIF="$PWD/landis_0.3.1.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"
cd "$LANDIS_DIR"
singularity run "$SIF" scenario.txt 2>&1 > out.txt

# Timing
time2=$(date +%s.%N)

# Report timing
echo "Total runtime      $(echo $time2 - $time0 | bc) s" >> out.txt
echo "- Directory prep   $(echo $time1 - $time0 | bc) s" >> out.txt
echo "- LANDIS exec      $(echo $time2 - $time1 | bc) s" >> out.txt

