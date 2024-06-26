# Running the pDT on LUMI

Note that all the input files are not included in this repository.

## General first-time setup

Clone this repository on LUMI:

    mkdir -p /scratch/project_465000915/$USER/
    cd /scratch/project_465000915/$USER/
    git clone https://github.com/BioDT/uc-forest-bird.git
    # git clone git@github.com:BioDT/uc-forest-bird.git  # alternative with ssh and push access
    cd uc-forest-bird

## Running LANDIS on LUMI

### First-time setup

Download `run_landis_template.zip` and `scenarios.zip` from cloud,
transfer them to LUMI under `uc-forest-bird` directory, and unzip:

    unzip run_landis_template.zip
    unzip scenarios.zip

Fetch the landis container:

    singularity pull --docker-login docker://ghcr.io/biodt/landis:0.3.1

### Running

Submit a batch job for a single run:

    sbatch -A project_465000915 scripts/submit_single.lumi.sh current BAU

Submit a batch job for a running all jobs in parallel on a single node:

    sbatch -A project_465000915 scripts/submit_all.lumi.sh

To zip all run directories (with `7141504` as an example job id):

    for d in run_landis_*_7141504; do zip -r $d.zip $d/ & done
