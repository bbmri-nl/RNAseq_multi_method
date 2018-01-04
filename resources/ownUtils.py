from os.path import basename
from sys import stderr
from pkg_resources import resource_string
import json


import pandas as pd
from cerberus import Validator
from snakemake.io import expand


def printValidationErrors(dic, depth=0):
    """
    This function prints the errors given by cerberus when validating
    a dictionary.
    """
    for x in dic:
        er = dic[x][0]
        if type(er) == dict:
            print("{}Errors for key {}:".format("\t"*depth, x))
            printValidationErrors(er, depth+1)
        else:
            print("{}Error for key {}: {}".format("\t"*depth, x, er))


#TODO save normalized config?
def checkConfig(config):
    """
    This function uses cerberus to check the given config dictionary
    with the schema. It then fills in the defaults for missing values
    and returns the completed config.
    """
    schema = json.loads(resource_string(__name__, "config_schema.json"))
    v = Validator(schema)
    passed = v.validate(config)
    if passed:
        return v.normalized(config)
    printValidationErrors(v.errors)
    exit(1)


def getMD5FromSampleSheet(wildcards, sampleSheet):
    """
    This function retrieves the MD5 for a file from the samplesheet.
    """
    full_path = lookForInputFile(wildcards, sampleSheet)
    row = sampleSheet.loc[sampleSheet["R1"] == full_path]
    md5_i = 1
    if len(row) == 0:
        row = sampleSheet.loc[sampleSheet["R2"] == full_path]
        md5_i = 3
    return row.iat[0,md5_i]


def getInputs(sampleSheet):
    """
    This function compiles a list of all input files noted in the
    samplesheet.
    """
    inputs = sampleSheet["R1"].tolist() + sampleSheet["R2"].tolist()
    out = [x for x in inputs if not pd.isnull(x)]
    return out


def lookForInputFile(wildcards, sampleSheet):
    """
    This function retrieves the full path for a file from the
    samplesheet.
    """
    inputs = getInputs(sampleSheet)
    for x in inputs:
        if wildcards.file == basename(x):
            return x


def getFastq(wildcards, sampleSheet):
    """
    This function retrieves the file path(s) for a specific sample/lane
    combination (both forward and reverse).
    """
    result = [sampleSheet.loc[wildcards.sample, wildcards.lane]["R1"]]
    if not isSingleEnd(wildcards.sample, sampleSheet):
        result.append(sampleSheet.loc[wildcards.sample, wildcards.lane]["R2"])
    return result


def adaptersAsParams(config):
    """
    This function turns the adapters noted in the Fastqc adapter lists
    mentioned in the config file into arguments which can be given to
    cutadapt.
    """
    if type(config["cutadapt"]["adapterFile"]) == str:
        files = [config["cutadapt"]["adapterFile"]]
    else:
        files = config["cutadapt"]["adapterFile"]
    out = ""
    for x in files:
        f1 = open(x, "r")
        for line in f1.readlines():
            if not line[0] in ["#", "\n"]:
                out += " -a {} ".format(line.split("\t")[-1].strip())
        f1.close()
    return out


def isSingleEnd(sample, sampleSheet):
    """
    This function checks whether a sample is paired- or single-end.
    """
    out = pd.isnull(sampleSheet.loc[sample, "R2"])
    try:
        out2 = out.any()
        return out2
    except AttributeError:
        return out


def getFilePerSample(samples, sampleSheet, form1, form2=None, **kwargs):
    """
    This function generates a list of filenames. For each sample
    a filename will be generated according to form1. If a sample
    is paired-end, form2 is used instead and a filename will be
    generated for both ends.
    """
    out = []
    for x in samples:
        if form2==None or isSingleEnd(x, sampleSheet):
            out += expand(form1, sample=x, **kwargs)
        else:
            out += expand(form2, sample=x, group=[1,2], **kwargs)
    return out


def getLanesForSample(sample, sampleSheet):
    return sampleSheet.loc[sample].index.tolist()


def getBasenames(files):
    """
    This function retrieves the basenames for a list of files.
    """
    out = []
    for x in files:
        out.append(basename(x))
    return out


def determineOutput(config, sampleSheet):
    """
    This function determines what output files need to be
    made by the snakemake pipeline.
    """
    mappers = [x for x in config["mappers"].keys()
        if config["mappers"][x]["include"]]
    countTypes = [x for x in config["counting"].keys()
        if config["counting"][x]["include"]]
    samples = set(sampleSheet.index.levels[0].tolist())
    inputs = getInputs(sampleSheet)
    out = []

    # raw fastqc results
    out += expand("raw_metrics/{file}_fastqc.html",
        file=getBasenames(inputs))
    out += expand("raw_metrics/{file}_fastqc.zip",
        file=getBasenames(inputs))

    # cleaned fastq files
    for sample in samples:
        out += getFilePerSample([sample], sampleSheet,
            "cleaned/{sample}_{lane}_cleaned.fastq.gz",
            "cleaned/{sample}_{lane}_cleaned_{group}.fastq.gz",
            lane=getLanesForSample(sample, sampleSheet))

        # cleaned fastqc resulst
        out += getFilePerSample([sample], sampleSheet,
            "cleaned/metrics/{sample}_{lane}_cleaned.fastq.gz_fastqc.html",
            "cleaned/metrics/{sample}_{lane}_cleaned_{group}.fastq.gz_fastqc.html",
            lane=getLanesForSample(sample, sampleSheet))

    # merged fastq files
    out += getFilePerSample(samples, sampleSheet,
        "merged/{sample}_merged.fastq.gz",
        "merged/{sample}_merged_{group}.fastq.gz")

    # bam and bai files
    for mapper in mappers:
        out += getFilePerSample(samples, sampleSheet,
            "{mapper}/{sample}/{sample}_{mapper}.bam",
            mapper=mapper)
        out += getFilePerSample(samples, sampleSheet,
            "{mapper}/{sample}/{sample}_{mapper}.bam.bai",
            mapper=mapper)

        # count tables
        for countType in countTypes:
            out += getFilePerSample(samples, sampleSheet,
            "expression_measures_{mapper}/{countType}/"
            "{sample}/{sample}.{countType}", mapper=mapper,
            countType=countType)
            out.append(
                "expression_measures_{mapper}/{countType}/"
                "all_samples.{countType}".format(mapper=mapper,
                countType=countType))

            # count metrics
            out.append("expression_measures_{mapper}/{countType}/"
                "metrics/metrics.html".format(mapper=mapper,
                countType=countType))
            out.append("expression_measures_{mapper}/{countType}/"
                "metrics/alignmentSummary.tsv".format(mapper=mapper,
                countType=countType))
            out.append("expression_measures_{mapper}/{countType}/"
                "metrics/alignmentSummaryPercentages.tsv".format(mapper=mapper,
                countType=countType))

    # get md5 files and add them
    out += expand("{file}.md5", file=out)

    # raw md5 check
    out += expand(".md5_check/{file}.OK", file=getBasenames(inputs))

    #print(out)
    #return ["raw_metrics/a.chr21.1.fq.gz_fastqc.html",
    #    "raw_metrics/a.chr21.1.fq.gz_fastqc.html.md5"] #for testing
    return out