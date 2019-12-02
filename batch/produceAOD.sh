#!/bin/bash
export MHC=$1
export MH=$2
export NEVENTS=$3
export JOB=$4
NAME=HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}

source $MCDIR/ChargedProduction/setenv.sh
cd $TMP

gfal-copy srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_$YEAR/${NAME}_${JOB}_DRP.root .

cmsDriver.py AOD --mc --eventcontent AODSIM runUnscheduled --python_filename ${NAME}_AOD_cfg.py --datatier AODSIM --conditions $CONDITIONS --step RAW2DIGI,RECO,EI --era $ERA --filein file:${NAME}_${JOB}_DRP.root --fileout file:${NAME}_${JOB}_AOD.root -n $NEVENTS

##Send to DESY dCache
gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/AOD_$YEAR
gfal-copy -f ${NAME}_${JOB}_AOD.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/AOD_$YEAR

cmsDriver.py MINIAOD --mc --python_filename ${NAME}_MINIAOD_cfg.py --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions $CONDITIONS --step PAT --era $ERA,run2_miniAOD_94XFall17 --filein file:${NAME}_${JOB}_AOD.root --fileout file:${NAME}_${JOB}_MINIAOD.root -n $NEVENTS

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/MINIAOD_$YEAR
gfal-copy -f ${NAME}_${JOB}_MINIAOD.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/MINIAOD_$YEAR
