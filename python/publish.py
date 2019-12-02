#!/usr/bin/env python

import sys
import os
import argparse
import time
import subprocess

from CRABAPI.RawCommand import crabCommand
from CRABClient.UserUtilities import config

def parser():
    parser = argparse.ArgumentParser()
    
    parser.add_argument("--MHc", type = int)
    parser.add_argument("--Mh", type = int)
    parser.add_argument("--sim-step", type = str)
    parser.add_argument("--year", type = int)

    return parser.parse_args()

def crabConfig(MHc, Mh, simStep, year):
    fileNames= subprocess.check_output(["gfal-ls", "srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/HPlusAndH_ToWHH_ToL4B_{}_{}/{}_{}".format(MHc, Mh, simStep, year)]).split("\n")[:-1]

    fileNames = ["/store/user/dbrunner/signal/HPlusAndH_ToWHH_ToL4B_{}_{}/{}_{}/{}".format(MHc, Mh, simStep, year, fName) for fName in fileNames if "root" in fName]

    ##Crab config
    crabConf = config()

    crabConf.General.requestName = 'Publish'
    crabConf.General.workArea = 'HPlusAndH_ToWHH_ToL4B_{}_{}'.format(MHc, Mh)
    crabConf.General.transferOutputs = True
    crabConf.General.transferLogs = False

    crabConf.JobType.psetName = 'ChargedProduction/Production/python/publish.py'
    crabConf.JobType.pluginName = 'Analysis'
    crabConf.JobType.pyCfgParams = ["MHc={}".format(MHc), "Mh={}".format(Mh)]
    crabConf.JobType.maxJobRuntimeMin = 120

    crabConf.Data.userInputFiles = fileNames
    crabConf.Data.splitting = 'FileBased'
    crabConf.Data.unitsPerJob = 360
    crabConf.Data.outLFNDirBase = "/store/user/dbrunner/signal/"
    crabConf.Data.publication = True
    crabConf.Data.outputDatasetTag = "{}_{}".format(simStep, year)
    crabConf.Data.outputPrimaryDataset = 'HPlusAndH_ToWHH_ToL4B_{}_{}'.format(MHc, Mh)

    crabConf.Site.whitelist = ["T2_DE_DESY"]
    crabConf.Site.storageSite = 'T2_DE_DESY'

    return crabConf

def main():
    args = parser()

    ##Submit jobs
    crabConf = crabConfig(args.MHc, args.Mh, args.sim_step, args.year)
    crabCommand('submit', config = crabConf)


if __name__ == "__main__":
    main()
