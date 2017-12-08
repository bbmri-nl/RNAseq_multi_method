from os.path import basename
from sys import stderr

import pandas as pd
from snakemake.io import expand

#TODO check config
def checkConfig(config):
    print("Config checking is not included yet.", file=stderr)


def getMD5FromSampleSheet(wildcards, sampleSheet):
    """
    This function retrieves the MD5 for a file from the samplesheet.
    """
    full_path = lookForInputFile(wildcards, sampleSheet)
    row = sampleSheet.loc[sampleSheet["R1"] == full_path]
    md5_i = 2
    if len(row) == 0:
        row = sampleSheet.loc[sampleSheet["R2"] == full_path]
        md5_i = 4
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
    This function retrives the full path for a file from the
    samplesheet.
    """
    inputs = getInputs(sampleSheet)
    for x in inputs:
        if wildcards.file == basename(x):
            return x


def get_fastq(wildcards, sampleSheet):
    """
    This function retrieves the file path(s) for a specific sample
    (forward/reverse combination).
    """
    try:
        field = "R{}".format(wildcards.group)
    except AttributeError:
        field = "R1"
    result = sampleSheet.loc[wildcards.sample, field]
    if type(result) == str:
        return [result]
    return result.tolist()


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


def isSingleEnd(x, sampleSheet):
    """
    This function checks whether a sample is paired- or single-end.
    """
    out = pd.isnull(sampleSheet.loc[x, "R2"])
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
        if isSingleEnd(x, sampleSheet) or form2==None:
            out.append(form1.format(sample=x, **kwargs))
        else:
            out += expand(form2, sample=x, group=[1,2], **kwargs)
    return out


def getBasenames(files):
    """
    This function retrieves the basenames for a list of files.
    """
    out = []
    for x in files:
        out.append(basename(x))
    return out


#TODO bam files
#TODO bai files
#TODO fragements_per_gene per mapper per sample
#TODO merged fragements_per_gene per mapper
def determineOutput(config, sampleSheet):
    """
    This function determines what output files need to be
    made by the snakemake pipeline.
    """
    mappers = config["mappers"].keys()
    samples = set(sampleSheet.index.tolist())
    inputs = getInputs(sampleSheet)
    out = []

    # raw fastqc results
    out += expand("raw_metrics/{file}_fastqc.html",
        file=getBasenames(inputs))
    out += expand("raw_metrics/{file}_fastqc.zip",
        file=getBasenames(inputs))

    # merged fastq files
    out += getFilePerSample(samples, sampleSheet,
        "merged/{sample}_merged.fastq.gz",
        "merged/{sample}_merged_{group}.fastq.gz")

    # cleaned fastq files
    out += getFilePerSample(samples, sampleSheet,
        "cleaned/{sample}_cleaned.fastq.gz",
        "cleaned/{sample}_cleaned_{group}.fastq.gz")

    # cleaned fastqc resulst
    out += getFilePerSample(samples, sampleSheet,
        "cleaned/metrics/{sample}_cleaned.fastq.gz_fastqc.html",
        "cleaned/metrics/{sample}_cleaned_{group}.fastq.gz_fastqc.html")

    # bam files
    for mapper in mappers:
        out += getFilePerSample(samples, sampleSheet,
            "{mapper}/{sample}/{sample}_{mapper}.bam",
            mapper=mapper)

    # get md5 files and add them
    out += expand("{file}.md5", file=out)

    # raw md5 check
    out += expand(".md5_check/{file}.OK", file=getBasenames(inputs))

    #print(out)
    #return ["raw_metrics/a.chr21.1.fq.gz_fastqc.html",
    #    "raw_metrics/a.chr21.1.fq.gz_fastqc.html.md5"] #for testing
    return out
