#!/usr/bin/env python

import sys
import os
import argparse
import subprocess

def parser():
    parser = argparse.ArgumentParser()
    
    parser.add_argument("--MHc", type = str, help = "Charged Higgs mass")
    parser.add_argument("--Mh", type = str, help = "Small Higgs mass")
    parser.add_argument("--events", type = str, help = "Number of events per jobs to be generated")
    parser.add_argument("--jobs", type = int, help = "Number of jobs for generation")
    parser.add_argument("--step", type = str, help = "Step in event generation", choices=["LHE", "GS", "AOD"])
    parser.add_argument("--resubmit", action="store_true", help = "Resubmit failed jobs")

    return parser.parse_args()

def submit(MHc, Mh, events, step, jobs):
    mcDir = os.environ["MCDIR"]
    workDir = "{}/{}_{}_{}".format(mcDir, step, MHc, Mh)
    
    for d in ["out", "log", "err"]:
        subprocess.call(["mkdir", "-p", "{}/{}".format(workDir, d)])

    condorSub = [
            "universe = vanilla",
            "executable = {}/ChargedProduction/batch/produce{}.sh".format(mcDir, step),
            "arguments = {}".format(" ".join([MHc, Mh, events, "$(job)", mcDir])),
            "log = {}/log/condor_$(job).log".format(workDir),
            "error = {}/err/condor_$(job).err".format(workDir),
            "getenv = True",
            "output = {}/out/condor_$(job).out".format(workDir),
    ]

    if step == "GS":
        condorSub.append("+RequestRuntime = {}".format(str(60*60*24)))

    with open("{}/condor.sub".format(workDir), "w") as condFile:
        for line in condorSub:
            condFile.write(line + "\n")

        condFile.write("queue job in ({})".format(" ".join([str(i) for i in jobs])))

    if step == "LHE":
        subprocess.call(["makeGridPack.sh", workDir, MHc, Mh])
    
    subprocess.call(["condor_submit", "{}/condor.sub".format(workDir)])

def main():
    ##Parser
    args = parser()

    ##Check for job numbers to be resubmitted
    if args.resubmit:
        dCache = "srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/user/dbrunner/signal/HPlusAndH_ToWHH_ToL4B_{}_{}/{}_{}".format(args.MHc, args.Mh, args.step, os.environ["YEAR"])

        files = subprocess.check_output(["gfal-ls", dCache])
        extFiles = [int(f.split("_")[-1].split(".")[0]) for f in files.split("\n") if f != ""]
        missingNr = list(set(range(args.jobs)) - set(extFiles))

    ##Submit jobs
    jobs = range(args.jobs) if not args.resubmit else missingNr
    submit(args.MHc, args.Mh, args.events, args.step, jobs)
    
if __name__ == "__main__":
    main()
