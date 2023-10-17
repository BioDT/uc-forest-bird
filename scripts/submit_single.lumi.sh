#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o landis.out
#SBATCH -p small
#SBATCH -n 1
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=1
#SBATCH -t 04:00:00

SIF="$PWD/landis_0.1.2.sif"

pushd LANDIS_run/
date
singularity run  --bind "$PWD" "$SIF" scenario.txt
date

# Fix Windows file paths
rmdir Metadata/ Metadata\\*/
for f in Metadata*.xml; do
    f_new="${f//\\//}";
    mkdir -p "$(dirname "$f_new")";
    mv "$f" "$f_new";
done
