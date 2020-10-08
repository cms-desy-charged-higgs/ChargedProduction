mkdir -p MCProduction
cd MCProduction
export MCDIR=$PWD

##Clone repo
git clone https://github.com/cms-desy-charged-higgs/ChargedProduction.git

##Check out genprudction
git clone https://github.com/cms-sw/genproductions
cd genproductions
git checkout UL2019

sed -i "/cd $MGBASEDIRORIG/wget https://2hdmc.hepforge.org/downloads/2HDMC-1.7.0.tar.gz\ntar xvf 2HDMC-1.7.0.tar.gz\nmv 2HDMC-1.7.0/MGME/2HDMC/ models/\ncommand rm -rf 2HDMC*\nsed -i 's/f77/gfortran/g' models/2HDMC/makefile" bin/MadGraph5_aMCatNLO/gridpack_generation.sh
