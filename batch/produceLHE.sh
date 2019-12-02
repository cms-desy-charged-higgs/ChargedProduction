#!/bin/bash
export MHC=$1
export MH=$2
export NEVENTS=$3
export JOB=$4
export MCDIR=$5
NAME=HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}

source $MCDIR/ChargedProduction/setenv.sh
cd $TMP

cp $MCDIR/LHE_${MHC}_${MH}/gridpack.tar.gz .
tar -xzf gridpack.tar.gz

./run.sh $NEVENTS 1 $JOB
gunzip events.lhe.gz
mv events.lhe ${NAME}_${JOB}.lhe

##Send to DESY dCache
gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/LHE_$YEAR
gfal-copy -f ${NAME}_${JOB}.lhe srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/LHE_$YEAR
