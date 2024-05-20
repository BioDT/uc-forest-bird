# Running the pDT on LUMI

Note that all the input files are not included in this repository.

## General preparations

Set the LUMI computational project:

    export PROJECT=project_465000915

Clone this repository on LUMI:

    mkdir -p /scratch/$PROJECT/$USER/
    cd /scratch/$PROJECT/$USER/
    git clone git@github.com:BioDT/uc-forest-bird.git
    cd uc-forest-bird

## Running LANDIS on LUMI

### Preparations

Download `run_landis_template.zip` and `scenarios.zip` from cloud, transfer to LUMI, and unzip:

    unzip run_landis_template.zip
    unzip scenarios.zip

Fetch the landis container:

    singularity pull --docker-login docker://ghcr.io/biodt/landis:0.3.1

### Running

Submit a batch job for a single run:

    sbatch scripts/submit_single.lumi.sh current BAU

Submit a batch job for a running all jobs in parallel on a single node:

    sbatch scripts/submit_all.lumi.sh

