#!/bin/bash

mkdir -p gridpacks

unset CMSSW_VERSION CMSSW_BASE
source /cvmfs/cms.cern.ch/cmsset_default.sh

MHC=$1
MH=$2

cd $MCDIR/genproductions/bin/MadGraph5_aMCatNLO/
mkdir -p cards/signal/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}

cp -f $MCDIR/ChargedProduction/cards/HPlusAndH_ToWHH_ToL4B_proc_card.dat cards/signal/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}_proc_card.dat
cp -f $MCDIR/ChargedProduction/cards/HPlusAndH_ToWHH_ToL4B_run_card.dat cards/signal/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}_run_card.dat
cp -f $MCDIR/ChargedProduction/SLHA/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}.shla cards/signal/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}_param_card.dat

echo "output HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}" >> cards/signal/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}_proc_card.dat

./gridpack_generation.sh HPlusAndH_ToWHH_ToL4B_${MHC}_${MH} cards/signal/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}

cd $MCDIR
source $MCDIR/ChargedProduction/setenv.sh
mv $MCDIR/genproductions/bin/MadGraph5_aMCatNLO/*tar* gridpacks
