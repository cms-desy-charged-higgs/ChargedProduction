# Production of signal Monte carlo for ChargedHiggs

## Installation
Get the installation script from the CharpedProduction repository:

`https://raw.githubusercontent.com/cms-desy-charged-higgs/ChargedProduction/master/install.sh`

The directory `MCProduction` is created and everything will be installed there.

## Usage

For each new shell source the script to set up the enviroment:

`source path-to-MCProduction/ChargedProduction/setenv.sh`

To send jobs with htcondor to produce signal MC, the `produce.py`  script is used. 
```
produce.py --help
usage: produce.py [-h] [--MHc MHC] [--Mh MH] [--events EVENTS] [--jobs JOBS]
                  [--step {LHE,GS,AOD}] [--resubmit]

optional arguments:
  -h, --help            show this help message and exit
  --MHc MHC             Charged Higgs mass
  --Mh MH               Small Higgs mass
  --events EVENTS       Number of events per jobs to be generated
  --jobs JOBS           Number of jobs for generation
  --step {LHE,GS,AOD}
                        Step in event generation
  --resubmit            Resubmit failed jobs
```

The production is splitted into three steps:

```
LHE: Production of one grid pack (locally) and the production of the LHE files from the grid pack
GS: Detector simulation with pythia and RAW to DIGI conversion
AOD: Production of AOD and MINIAOD files
```

One example for usage of the script to produce LHE files:

`produce.py --MHc 400 --Mh 100 --events 5000 --jobs 2000 --step LHE`
