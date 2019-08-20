#!/bin/bash

export HOME=./
export NAME=HPlusAndH_ToWHH_ToL4B_$1_$2
export CONDITIONS=94X_mc2017_realistic_v14
export ERA=Run2_2017
export N=$4

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc700

eval `scramv1 project CMSSW CMSSW_9_4_7`
cd CMSSW_9_4_7/src/
eval `scramv1 runtime -sh`

mkdir -p Configuration/GenProduction/python

mv ../../cHiggsfragment.py ./Configuration/GenProduction/python
mv ../../command_$1_$2.txt ./
mv ../../$NAME.shla ./
mv ../../x509 ./

export X509_USER_PROXY=$CMSSW_BASE/src/x509

scram b

mv ../../MG5_aMC_v2_6_4 ./

./MG5_aMC_v2_6_4/bin/mg5_aMC command_$1_$2.txt 
gunzip $NAME/Events/run_01/unweighted_events.lhe.gz 
mv $NAME/Events/run_01/unweighted_events.lhe ${NAME}_$3.lhe

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/LHE_2017
gfal-copy -f ${NAME}_$3.lhe srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/LHE_2017
 
cmsDriver.py LHEtoEDM --filein file:${NAME}_$3.lhe --fileout file:${NAME}_$3_pLHE.root --mc --eventcontent LHE --datatier LHE --conditions $CONDITIONS --era $ERA --step NONE --python_filename ${NAME}_pLHE_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $N 

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/pLHE_2017
gfal-copy -f ${NAME}_$3_pLHE.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/pLHE_2017

cmsDriver.py Configuration/GenProduction/python/cHiggsfragment.py --filein file:${NAME}_$3_pLHE.root --fileout file:${NAME}_$3_GS.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions $CONDITIONS --beamspot Realistic25ns13TeVEarly2017Collision --step GEN,SIM --nThreads 1 --geometry DB:Extended --era $ERA --python_filename ${NAME}_GS_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $N

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_2017
gfal-copy -f ${NAME}_$3_GS.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/GS_2017

cmsDriver.py DIGI --filein file:${NAME}_$3_GS.root --fileout file:${NAME}_$3_DRP.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-MCv2_correctPU_94X_mc2017_realistic_v9-v1/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions $CONDITIONS --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 --datamix PreMix --era $ERA --python_filename ${NAME}_DRP_cfg.py --customise Configuration/DataProcessing/Utils.addMonitoring -n $N

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_2017
gfal-copy -f ${NAME}_$3_DRP.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/DRP_2017

cmsDriver.py AOD --mc --eventcontent AODSIM runUnscheduled --python_filename ${NAME}_AOD_cfg.py --datatier AODSIM --conditions $CONDITIONS --step RAW2DIGI,RECO,EI --era $ERA --filein file:${NAME}_$3_DRP.root --fileout file:${NAME}_$3_AOD.root -n $N

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/AOD_2017
gfal-copy -f ${NAME}_$3_AOD.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/AOD_2017

cmsDriver.py MINIAOD --mc --python_filename ${NAME}_MINIAOD_cfg.py --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions $CONDITIONS --step PAT --era $ERA,run2_miniAOD_94XFall17 --filein file:${NAME}_$3_AOD.root --fileout file:${NAME}_$3_MINIAOD.root -n $N

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/MINIAOD_2017
gfal-copy -f ${NAME}_$3_MINIAOD.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/MINIAOD_2017

cp *MINIAOD.root ../../
cd ../../ 

eval `scramv1 project CMSSW CMSSW_10_2_15`
cd CMSSW_10_2_15/src/
eval `scramv1 runtime -sh`

scram b

cp ../../*MINIAOD.root .

cmsDriver.py NANOAOD --mc --eventcontent NANOAODSIM --python_filename ${NAME}_NANOAOD_cfg.py --datatier NANOAODSIM --conditions 102X_mc2017_realistic_v7 --era $ERA,run2_nanoAOD_94XMiniAODv2 --step NANO --filein file:${NAME}_$3_MINIAOD.root --fileout file:${NAME}_$3_NANOAOD.root -n $N --customise_commands 'process.particleLevelSequence.remove(process.genParticles2HepMCHiggsVtx);process.particleLevelSequence.remove(process.rivetProducerHTXS);process.particleLevelTables.remove(process.HTXSCategoryTable)'

gfal-mkdir -p srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/NANOAOD_2017
gfal-copy -f ${NAME}_$3_NANOAOD.root srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/$NAME/NANOAOD_2017
