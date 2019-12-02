mkdir -p MCProduction
cd MCProduction
export MCDIR=$PWD

##Clone repo
git clone https://github.com/cms-desy-charged-higgs/ChargedProduction.git

##Install CMSSW
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc700

eval `scramv1 project CMSSW CMSSW_9_4_7`
cd CMSSW_9_4_7/src/
eval `scramv1 runtime -sh`

mkdir -p Configuration/GenProduction/python
cp $MCDIR/ChargedProduction/python/cHiggsfragment.py ./Configuration/GenProduction/python
scram b

cd $MCDIR

##Install madgraph and 2HDM model
wget https://launchpad.net/mg5amcnlo/2.0/2.6.x/+download/MG5_aMC_v2.6.7.tar.gz
tar xvf MG5_aMC_v2.6.7.tar.gz
command rm -rf MG5_aMC_v2.6.7.tar.gz
wget https://2hdmc.hepforge.org/downloads/2HDMC-1.7.0.tar.gz
tar xvf 2HDMC-1.7.0.tar.gz
mv 2HDMC-1.7.0/MGME/2HDMC/ MG5_aMC_v2_6_7/models/
command rm -rf 2HDMC*

sed -i 's/f77/gfortran/g' MG5_aMC_v2_6_7/models/2HDMC/makefile

##Install LHAPDF
wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-6.2.1.tar.gz -O LHAPDF-6.2.1.tar.gz
tar xfv LHAPDF-6.2.1.tar.gz
cd LHAPDF-6.2.1
./configure --prefix $PWD/lhapdf6
make -j 20 && make install

export PATH=$PATH:$MCDIR/LHAPDF-6.2.1/lhapdf6/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MCDIR/LHAPDF-6.2.1/lhapdf6/lib
export PYTHONPATH=$PYTHONPATH:$MCDIR/LHAPDF-6.2.1/lhapdf6/lib/python2.7/site-packages/
export LHAPDF_DATA_PATH=$MCDIR/LHAPDF-6.2.1/lhapdf6/share/LHAPDF/

lhapdf install NNPDF31_nnlo_hessian_pdfas

cd .. 
command rm -rf LHAPDF-6.2.1.tar.gz

##Install madanalysis
wget https://launchpad.net/madanalysis5/trunk/v1.7/+download/ma5_v1.7.tgz
tar -xvf ma5_v1.7.tgz
command rm ma5_v1.7.tgz

