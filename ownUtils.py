import pandas as pd

def checkConfig():
    print("Config checking is not included yet.")


def getInputs(samples):
    inputs = samples["R1"].tolist() + samples["R2"].tolist()
    out = [x for x in inputs if not pd.isnull(x)]
    return out


def lookForInputFile(wildcards, samples):
    inputs = getInputs(samples)
    for x in inputs:
        if wildcards.file == x.split("/")[-1]:
            return x


def get_fastq(wildcards, samples):
    try:
        field = "R{}".format(wildcards.group)
    except AttributeError:
        field = "R1"
    result = samples.loc[wildcards.sample, field]
    if type(result) == str:
        return [result]
    return result.tolist()


def adaptersAsParams(config):
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


def determineOutput(config, samples):
    mappers = config["mappers"].keys()
    print(mappers)
    return ["cleaned/A_cleaned_1.fastq.gz", "cleaned/A_cleaned_2.fastq.gz",
        "cleaned/B_cleaned.fastq.gz", "raw_metrics/a.chr21.1.fq.gz_fastqc.html",
        "cleaned/metrics/A_cleaned_1.fastq.gz_fastqc.html"]
