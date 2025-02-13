#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o run_landis_%j.out
#SBATCH -p largemem
#SBATCH -N 1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=2
#SBATCH --mem=0
#SBATCH -t 24:00:00

ROOT_DIR="$1"
if [ -z "$ROOT_DIR" ]; then echo "set directory"; exit 1; fi

for CLIMATE in current 4.5 8.5; do
    for HARVEST in BAU EXT10 EXT30 GTR30 NTLR NTSR SA; do
        srun -n 1 bash scripts/submit_single.lumi.sh "$ROOT_DIR" "$CLIMATE" "$HARVEST" &
    done
done

wait

