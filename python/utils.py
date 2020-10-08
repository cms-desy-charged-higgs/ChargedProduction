import FWCore.ParameterSet.Config as cms

def setGridDir(process):
    process.externalLHEProducer.args = cms.vstring("/srv/gridpack.tar.xz")

    return process
