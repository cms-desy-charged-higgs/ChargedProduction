##Set proxy dir
export X509_USER_PROXY=$HOME/.globus/x509

##Set dir
MCDIR=$(readlink -f $BASH_SOURCE)
export MCDIR=${MCDIR/"/ChargedProduction/setenv.sh"}

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/cms.cern.ch/crab3/crab.sh ""

##Voms command
alias voms="voms-proxy-init --voms cms:/cms/dcms --valid 168:00"
