import FWCore.ParameterSet.Config as cms
from FWCore.ParameterSet.VarParsing import VarParsing

import subprocess

##Argument parsing
options = VarParsing()
options.register("MHc", "", VarParsing.multiplicity.singleton, VarParsing.varType.string, "")
options.register("Mh", "", VarParsing.multiplicity.singleton, VarParsing.varType.string, "")

options.parseArguments()

process = cms.Process('Publish')
process.load("FWCore.MessageLogger.MessageLogger_cfi")
process.MessageLogger.cerr.FwkReport.reportEvery = 1000

process.source = cms.Source("PoolSource",  fileNames = cms.untracked.vstring(""))
process.source.duplicateCheckMode = cms.untracked.string('noDuplicateCheck')

outName = "HPlusAndH_ToWHH_ToL4B_{}_{}.root".format(options.MHc, options.Mh)
process.output = cms.OutputModule("PoolOutputModule", fileName = cms.untracked.string(outName))
process.out = cms.EndPath(process.output)

