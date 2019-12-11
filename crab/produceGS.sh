#!/bin/bash

##Set Production variables
export CONDITIONS=94X_mc2017_realistic_v14
export ERA=Run2_2017
export YEAR=2017

export MHC="$(cut -d'=' -f2 <<<"$2")"
export MH="$(cut -d'=' -f2 <<<"$3")"
export NEVENTS="$(cut -d'=' -f2 <<<"$4")"
export JOB="$(cut -d'=' -f2 <<<"$5")"
NAME=HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}

export X509_USER_PROXY=$PWD/x509

gfal-copy srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/LHE_$YEAR/${NAME}_${JOB}.lhe .

gfal-copy srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_$YEAR/${NAME}_${JOB}_GS.root .

if [ ! -f "${NAME}_${JOB}_GS.root" ]; then 
    cmsDriver.py Configuration/GenProduction/python/cHiggsfragment.py --filein file:${NAME}_${JOB}.lhe --fileout file:${NAME}_${JOB}_GS.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions $CONDITIONS --beamspot Realistic25ns13TeVEarly2017Collision --step GEN,SIM --nThreads 1 --geometry DB:Extended --era $ERA --python_filename ${NAME}_${JOB}_GS_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $NEVENTS

    ##Send to DESY dCache
    gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_$YEAR
    gfal-copy -f ${NAME}_${JOB}_GS.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_$YEAR
fi

cmsDriver.py DIGI --filein file:${NAME}_${JOB}_GS.root --fileout file:${NAME}_${JOB}_DRP.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-MCv2_correctPU_94X_mc2017_realistic_v9-v1/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions $CONDITIONS --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 --datamix PreMix --era $ERA --python_filename ${NAME}_DRP_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $NEVENTS

##Send to DESY dCache
gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_$YEAR
gfal-copy -f ${NAME}_${JOB}_DRP.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_$YEAR

cmsRun -j FrameworkJobReport.xml -p PSet.py
