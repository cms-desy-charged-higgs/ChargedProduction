#!/bin/bash

cd $1
MHC=$2
MH=$3

if [ ! -f "madCommands.txt" ]; then    
    ##Write command for madgraph
    echo -e "import model_v4 2HDMC" >> madCommands.txt
    echo -e "define hc = h- h+" >> madCommands.txt
    echo -e "define w = w+ w-" >> madCommands.txt
    echo -e "define l = l+ l-" >> madCommands.txt
    echo -e "define v = vl vl~" >> madCommands.txt
    echo -e "generate p p > hc h1, h1 > b b~, (hc > h1 w, h1 > b b~, w > l v)" >> madCommands.txt
    echo -e "add process p p > hc h1 j, h1 > b b~, (hc > h1 w, h1 > b b~, w > l v)" >> madCommands.txt
    echo -e "add process p p > hc h1 j j, h1 > b b~, (hc > h1 w, h1 > b b~, w > l v)" >> madCommands.txt
    echo -e "set automatic_html_opening False" >> madCommands.txt
    echo -e "output HPlusAndH_ToWHH_ToL4B" >> madCommands.txt
    echo -e "launch HPlusAndH_ToWHH_ToL4B" >> madCommands.txt
    echo -e "${MCDIR}/ChargedProduction/SLHA/HPlusAndH_ToWHH_ToL4B_${MHC}_${MH}.shla" >> madCommands.txt
    echo -e "set pdlabel lhapdf" >> madCommands.txt 
    echo -e "set lhaid 306000" >> madCommands.txt
    echo -e "set use_syst .true." >> madCommands.txt 
    echo -e "set gridpack .true." >> madCommands.txt 
    echo -e "done" >> madCommands.txt  

    ##Extract grid pack, compile and repack again
    $MCDIR/MG5_aMC_v2_6_7/bin/mg5_aMC madCommands.txt
    mv HPlusAndH_ToWHH_ToL4B/run_01_gridpack.tar.gz .
    tar -xvf run_01_gridpack.tar.gz
    mv run_01_gridpack.tar.gz gridpack_uncompiled.tar.gz
    cd madevent/bin/
    ./compile
    ./clean4grid
    cd ..
    cd ..
    tar -czvf gridpack.tar.gz madevent/ run.sh
    command rm -rf madevent run.sh

else
    echo "Gridpack is already produced"
fi
