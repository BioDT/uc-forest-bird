#!/bin/bash -l
#SBATCH -J landis
#SBATCH -o run_landis_%j.out
#SBATCH -p largemem
#SBATCH -N 1
#SBATCH --ntasks-per-node=21
#SBATCH --cpus-per-task=6
#SBATCH --mem=0
#SBATCH -t 24:00:00

for CLIMATE in current 4.5 8.5; do
    for HARVEST in BAU EXT10 EXT30 GTR30 NTLR NTSR SA; do
        srun -n 1 -o "run_landis_${CLIMATE}_${HARVEST}_${SLURM_JOB_ID}.out" bash scripts/submit_single.lumi.sh $CLIMATE $HARVEST &
    done
done

wait

