#!/bin/bash
export MHC=$1
export MH=$2
export NEVENTS=$3
export JOB=$4
NAME=HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}

source $MCDIR/ChargedProduction/setenv.sh
cd $TMP

gfal-copy srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/LHE_$YEAR/${NAME}_${JOB}.lhe .

cmsDriver.py Configuration/GenProduction/python/cHiggsfragment.py --filein file:${NAME}_${JOB}.lhe --fileout file:${NAME}_${JOB}_GS.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions $CONDITIONS --beamspot Realistic25ns13TeVEarly2017Collision --step GEN,SIM --nThreads 1 --geometry DB:Extended --era $ERA --python_filename ${NAME}_${JOB}_GS_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $NEVENTS

##Send to DESY dCache
gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_$YEAR
gfal-copy -f ${NAME}_${JOB}_GS.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_$YEAR

cmsDriver.py DIGI --filein file:${NAME}_${JOB}_GS.root --fileout file:${NAME}_${JOB}_DRP.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-MCv2_correctPU_94X_mc2017_realistic_v9-v1/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions $CONDITIONS --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 --datamix PreMix --era $ERA --python_filename ${NAME}_DRP_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $NEVENTS

##Send to DESY dCache
gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_$YEAR
gfal-copy -f ${NAME}_${JOB}_DRP.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_$YEAR
