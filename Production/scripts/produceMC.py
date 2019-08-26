#!/usr/bin/env python

import sys
import os
import argparse

sys.path.append("/usr/lib64/python2.6/site-packages/")
import htcondor

def parser():
    parser = argparse.ArgumentParser()
    
    parser.add_argument("--MHc", type = int)
    parser.add_argument("--Mh", type = int)
    parser.add_argument("--events-per-run", type = int, default = 2000)
    parser.add_argument("--runs", type = int, default = 5000)

    return parser.parse_args()

def setMadgraph():
    commands = [
                "wget https://launchpad.net/mg5amcnlo/2.0/2.6.x/+download/MG5_aMC_v2.6.6.tar.gz",
                "tar -xf MG5_aMC_v2.6.6.tar.gz",
                "rm MG5_aMC_v2.6.6.tar.gz",
                "wget https://2hdmc.hepforge.org/downloads/2HDMC-1.7.0.tar.gz",
                "tar -xf 2HDMC-1.7.0.tar.gz",
                "mv 2HDMC-1.7.0/MGME/2HDMC/ MG5_aMC_v2_6_6/models/",
                "rm -rf 2HDMC-1.7.0*",
                "mv MG5_aMC_v2_6_6/ {}/src/ChargedProduction/".format(os.environ["CMSSW_BASE"]),
    ]

    for command in commands:
        os.system(command)

    print("!!!! Change in MG5_aMC_v2_6_6/models/2HDMC/makefile f77 to gfortran !!!!")


def writeCommand(MHc, Mh, nEvents):
    commands = [
                "import model_v4 2HDMC",
                "set fortran_compiler gfortran",
                "define hc = h- h+",
                "define w = w+ w-",
                "define l = l+ l-",
                "define v = vl vl~",
                "generate p p > hc h1, h1 > b b~, (hc > h1 w, h1 > b b~, w > l v)",
                "add process p p > hc h1 j, h1 > b b~, (hc > h1 w, h1 > b b~, w > l v)",
                "add process p p > hc h1 j j, h1 > b b~, (hc > h1 w, h1 > b b~, w > l v)",
                "output HPlusAndH_ToWHH_ToL4B_{}_{}".format(MHc, Mh),
                "launch HPlusAndH_ToWHH_ToL4B_{}_{}".format(MHc, Mh),
                "HPlusAndH_ToWHH_ToL4B_{}_{}.shla".format(MHc, Mh),
                "set nevents {}".format(nEvents),
                "done",       
    ]

    with open(os.environ["CMSSW_BASE"] + "/src/command_{}_{}.txt".format(MHc, Mh), "w") as f: 
        for command in commands:
            f.write(command)
            f.write("\n")

def condorSubmit(MHc, Mh, run, nEvents):
    job = htcondor.Submit({})
    schedd = htcondor.Schedd()

    inputFiles = [
                    os.environ["CMSSW_BASE"] + "/src/ChargedProduction/Production/python/cHiggsfragment.py",
                    os.environ["CMSSW_BASE"] + "/src/ChargedProduction/MG5_aMC_v2_6_6",
                    os.environ["CMSSW_BASE"] + "/src/command_{}_{}.txt".format(MHc, Mh), 
                    os.environ["CMSSW_BASE"] + "/src/ChargedProduction/SLHA/HPlusAndH_ToWHH_ToL4B_{}_{}.shla".format(MHc, Mh),
                    os.environ["CMSSW_BASE"] + "/src/x509",                                              
                    os.environ["HOME"] + "/.dasmaps/"
    ]

    outdir = "{}/Signal/HPlusAndH_ToWHH_ToL4B_{}_{}/".format(os.environ["CHDIR"], MHc, Mh)
    os.system("mkdir -p {}".format(outdir)) 

    job["executable"] = "{}/src/ChargedProduction/Production/batch/produceMC.sh".format(os.environ["CMSSW_BASE"])
    job["arguments"] = " ".join([str(i) for i in [MHc, Mh, run, nEvents]])
    job["universe"] = "vanilla"

    job["should_transfer_files"] = "YES"
    job["transfer_input_files"] = ",".join(inputFiles)
    job["log"] = "{}/job_{}.log".format(outdir, run)
    job["output"] = "{}/job_{}.out".format(outdir, run)
    job["error"] = "{}/job_{}.err".format(outdir, run)

    job["on_exit_hold"] = "(ExitBySignal == True) || (ExitCode != 0)"  
    job["periodic_release"] =  "(NumJobStarts < 100) && ((CurrentTime - EnteredCurrentStatus) > 60)"

    job["+RequestRuntime"]    = "{}".format(60*60*12)

    def submit(schedd, job):
        with schedd.transaction() as txn:
            job.queue(txn)
          
    while(True):
        try: 
            submit(schedd, job)
            print("Submit job {}".format(run))
            break    

        except:
            pass

def main():
    args = parser()

    os.system("chmod 755 {}".format(os.environ["X509_USER_PROXY"])) 
    os.system("cp -u {} {}/src/".format(os.environ["X509_USER_PROXY"], os.environ["CMSSW_BASE"])) 

    if not os.path.isdir(os.environ["CMSSW_BASE"] + "/src/ChargedProduction/MG5_aMC_v2_6_6"):
        setMadgraph()
        return 0

    writeCommand(args.MHc, args.Mh, args.events_per_run)

    for run in range(args.runs):
        condorSubmit(args.MHc, args.Mh, run, args.events_per_run)
    
if __name__ == "__main__":
    main()
