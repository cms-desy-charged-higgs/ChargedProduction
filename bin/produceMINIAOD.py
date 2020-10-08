#!/usr/bin/env python

import os
import argparse

from CRABClient.UserUtilities import config
from CRABAPI.RawCommand import crabCommand

def parser():
    parser = argparse.ArgumentParser(description = "Submit AOD production with crab", formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("--MHc", type=int, help = "Charged higgs mass")
    parser.add_argument("--Mh", type=int, help = "Small higgs mass")
    parser.add_argument("--year", type=int, help = "Era")

    return parser.parse_args()

def crabConfig(MHc, Mh, year):
    crabConf = config()

    crabConf.General.requestName = "MINIAOD_{}".format(year)
    crabConf.General.workArea = "{}/HPlusAndH_ToWHH_ToL4B_{}_{}".format(os.environ["MCDIR"], MHc, Mh)
    crabConf.General.transferOutputs = True
    crabConf.General.transferLogs = False

    crabConf.JobType.pluginName = "Analysis"
    crabConf.JobType.psetName = "cmsRunConfig.py"
    crabConf.JobType.maxMemoryMB = 3000
    crabConf.JobType.maxJobRuntimeMin = 27*60

    crabConf.Data.inputDataset = "/HPlusAndH_ToWHH_ToL4B_{}_{}/dbrunner-AOD-{}-f7070e7c255fcf9571a9d7fc68b0de97/USER".format(MHc, Mh, year)
    crabConf.Data.inputDBS = "phys03"
    crabConf.Data.splitting = "EventAwareLumiBased"
    crabConf.Data.unitsPerJob = 20000
    crabConf.Data.totalUnits = crabConf.Data.unitsPerJob * 2000
    crabConf.Data.outLFNDirBase = "/store/user/dbrunner/signal/"
    crabConf.Data.publication = True
    crabConf.Data.outputDatasetTag = "MINIAOD-{}".format(year)

    crabConf.Site.storageSite = "T2_DE_DESY"
    crabConf.User.voGroup = "dcms"

    return crabConf

def main():
    args = parser()

    crabConf = crabConfig(args.MHc, args.Mh, args.year)
    crabCommand("submit", config=crabConf)

if __name__ == "__main__":
    main()

