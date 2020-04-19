#!/bin/bash

##Set Production variables
export CONDITIONS=94X_mc2017_realistic_v14
export ERA=Run2_2017
export YEAR=2017
export NAME=HPlusAndH_ToWHH_ToL2B2Tau

MHC=$1
MH=$2

case $3 in
    "GEN")
        mkdir -p $CMSSW_BASE/src/Configuration/GenProduction/python/
        cp -f $MCDIR/ChargedProduction/python/cHiggsfragment.py $CMSSW_BASE/src/Configuration/GenProduction/python/

        cp $MCDIR/gridpacks/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}_*_tarball.tar.xz gridpack.tar.xz

        cmsDriver.py Configuration/GenProduction/python/cHiggsfragment.py --fileout file:${NAME}_${MHC}_${MH}.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions $CONDITIONS --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN,SIM --nThreads 1 --geometry DB:Extended --era $ERA --python_filename cmsRunConfig.py -n 10 --no_exec

        produceGen.py --MHc $MHC --Mh $MH --year $YEAR
        rm gridpack.tar.xz cmsRunConfig.py*
        ;;

    "DRP")
        cmsDriver.py DIGI --fileout file:${NAME}_${MHC}_${MH}.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-MCv2_correctPU_94X_mc2017_realistic_v9-v1/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions $CONDITIONS --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 --datamix PreMix --era $ERA --python_filename cmsRunConfig.py --customise Configuration/DataProcessing/Utils.addMonitoring -n 10 --no_exec

        produceDRP.py --MHc $MHC --Mh $MH --year $YEAR
        rm cmsRunConfig.py*
        ;;

    "AOD")
        cmsDriver.py AOD --mc --eventcontent AODSIM runUnscheduled --python_filename cmsRunConfig.py --datatier AODSIM --conditions $CONDITIONS --step RAW2DIGI,RECO,EI --era $ERA --fileout file:${NAME}_${MHC}_${MH}.root -n 10 --no_exec

        produceAOD.py --MHc $MHC --Mh $MH --year $YEAR
        rm cmsRunConfig.py*
        ;;

    "MINIAOD")
        cmsDriver.py MINIAOD --mc --python_filename cmsRunConfig.py --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions $CONDITIONS --step PAT --era $ERA,run2_miniAOD_94XFall17 --fileout file:${NAME}_${MHC}_${MH}.root -n 10 --no_exec

        produceMINIAOD.py --MHc $MHC --Mh $MH --year $YEAR
        rm cmsRunConfig.py*
        ;;

    *)
        echo "Invalid option: $1"
        echo "Please use this options: {GEN, DRP}"
        return 1
        ;;

esac
