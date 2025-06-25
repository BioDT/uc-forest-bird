# Running the pDT on LUMI

The instructions here use a generic LUMI project `$PROJECT`. You can set variable to the actual project code like this:

    export PROJECT=project_462000865

Note that all the input files are not included in this repository.

## General first-time setup

Clone this repository on LUMI:

    mkdir -p /scratch/$PROJECT/$USER/
    cd /scratch/$PROJECT/$USER/
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

    sbatch -A $PROJECT scripts/submit_single.lumi.sh runs/NAME current BAU

Submit a batch job for a running all jobs in parallel on a single node:

    sbatch -A $PROJECT scripts/submit_all.lumi.sh runs/NAME

To zip run directory:

    zip -r NAME.zip runs/NAME


## Running HMSC, analysis scripts, and RStudio on LUMI

### First-time setup

Fetch the R container:

    export SINGULARITY_DOCKER_USERNAME=...  # github username
    export SINGULARITY_DOCKER_PASSWORD=...  # github token
    singularity pull --disable-cache docker://ghcr.io/biodt/forest-bird:0.3.0

### Running HMSC

Submit a batch job running HMSC for all scenarios:

    # Run first half of the cases as the number of simultaneous jobs is limited
    sbatch -A $PROJECT --array=0-199 scripts/run_hmsc.lumi.sh

    # After these jobs have finished, run the remaining cases
    sbatch -A $PROJECT --array=200-335 scripts/run_hmsc.lumi.sh

### Running analysis scripts

Submit a batch job running all analysis scripts for the given run directory (output directory can be changed):

    sbatch -A $PROJECT scripts/run_analysis.lumi.sh runs/NAME/run_JOBID/ runs/NAME/run_JOBID/results_output

### Running RStudio

1. Login to https://www.lumi.csc.fi/
2. Launch Desktop app (default settings are ok)
3. Connect to the Desktop session
4. In the desktop view, right-click the desktop and select 'Open Terminal Here'
5. In the terminal, run the following commands:

       # Enter the project directory
       cd /scratch/$PROJECT/$USER/uc-forest-bird

       # Launch RStudio
       bash scripts/run_rstudio.lumi.sh

