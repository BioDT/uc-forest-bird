#!/bin/bash -l
#SBATCH -J hmsc
#SBATCH -o run_hmsc_%j.out
#SBATCH -p small
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G
#SBATCH -t 4:00:00
#SBATCH --array=0-0
##SBATCH --array=0-335

# List all input combinations
inputs=()
for climate in current 4.5 8.5; do
    for harvest in BAU EXT10 EXT30 GTR30 NTLR NTSR SA; do
       for year in {5..80..5}; do
           inputs+=("${climate}_${harvest}/${year}")
       done
   done
done

# Choose one input
input=${1:-${inputs[$SLURM_ARRAY_TASK_ID]}}
echo $input
echo "$SLURM_ARRAY_TASK_ID of ${#inputs[@]}"

# Execute script
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
SIF="$PWD/forest-bird_0.3.0.sif"
export SINGULARITY_BIND="/pfs,/scratch,/projappl,/project,/flash,/appl"
singularity run "$SIF" "scripts/10_make_HMSC_predictions.R" "$input"

