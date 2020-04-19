##Set proxy dir
export X509_USER_PROXY=$HOME/.globus/x509

##Set dir
MCDIR=$(readlink -f $BASH_SOURCE)
export MCDIR=${MCDIR/"/ChargedProduction/setenv.sh"}

cd $MCDIR/CMSSW_9_4_7/src

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/cms.cern.ch/crab3/crab.sh
eval `scramv1 runtime -sh`
scram b

cd $MCDIR

##Enviroment variables
export PATH=$PATH:$MCDIR/ChargedProduction/bin:$MCDIR/LHAPDF-6.2.1/lhapdf6/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MCDIR/LHAPDF-6.2.1/lhapdf6/lib:/cvmfs/grid.cern.ch/emi-ui-3.17.1-1.el6umd4v5/usr/lib64/
export PYTHONPATH=$PYTHONPATH:$MCDIR/LHAPDF-6.2.1/lhapdf6/lib/python2.7/site-packages/
export LHAPDF_DATA_PATH=$MCDIR/LHAPDF-6.2.1/lhapdf6/share/LHAPDF/

##Set Production variables
export CONDITIONS=94X_mc2017_realistic_v14
export ERA=Run2_2017
export YEAR=2017

##Voms command
alias voms="voms-proxy-init --voms cms:/cms/dcms --valid 168:00"
