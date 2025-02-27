#!/bin/bash -l

SIF="$PWD/forest-bird_0.3.0.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"
singularity exec "$SIF" rstudio

