#!/bin/bash

RUN_DIR="$1"
if [ -z "$RUN_DIR" ]; then echo "set run directory"; exit 1; fi
if [ ! -d "$RUN_DIR" ]; then echo "directory missing: $RUN_DIR"; exit 1; fi

RESULTS_DIR="${2:-results}"

SIF="$PWD/forest-bird_0.2.1.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"
for script in analysis/visualize_agbiomass.R; do
    echo $script
    singularity run "$SIF" "$script" "$RUN_DIR" "$RESULTS_DIR"
done

