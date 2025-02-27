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

Prepare a run directory with the NAME of choice:

    mkdir -p runs/NAME
    cp -r run_landis_template runs/NAME/landis_template
    cp -r scenarios runs/NAME/scenarios

Fetch the landis container:

    export SINGULARITY_DOCKER_USERNAME=...  # github username
    export SINGULARITY_DOCKER_PASSWORD=...  # github token
    singularity pull --disable-cache docker://ghcr.io/biodt/landis:0.3.1

### Running

Submit a batch job for a single run:

    sbatch -A project_465000915 scripts/submit_single.lumi.sh runs/NAME current BAU

Submit a batch job for a running all jobs in parallel on a single node:

    sbatch -A project_465000915 scripts/submit_all.lumi.sh runs/NAME

To zip run directory:

    zip -r NAME.zip runs/NAME


## Running analysis scripts on LUMI

### First-time setup

Fetch the R container:

    export SINGULARITY_DOCKER_USERNAME=...  # github username
    export SINGULARITY_DOCKER_PASSWORD=...  # github token
    singularity pull --disable-cache docker://ghcr.io/biodt/forest-bird:0.2.1

### Running

Submit a batch job running all analysis scripts for the given run directory (output directory can be changed):

    sbatch -A project_465000915 scripts/run_analysis.lumi.sh runs/NAME/run_JOBID/ results_output

