# Running the pDT on LUMI

Note that all the input files are not included in this repository.

## Preparations

Set the LUMI computational project:

    export PROJECT=project_465000915

Clone this repository on LUMI:

    mkdir -p /scratch/$PROJECT/$USER/
    cd /scratch/$PROJECT/$USER/
    git clone git@github.com:BioDT/uc-forest-bird.git
    cd uc-forest-bird

Download `run_landis_template.zip` from cloud, transfer it to LUMI, and unzip:

    unzip run_landis_template.zip

Fetch the landis container:

    singularity pull --docker-login docker://ghcr.io/biodt/landis:0.3.0

## Running LANDIS on LUMI

Submit a batch job:

    sbatch scripts/submit_single.lumi.sh current BAU

