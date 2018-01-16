#TODO add vcfstats
#TODO adjust bamstats rule so it doesn't need to load the
    # biopet module (lwo priority; wait for jar release)
#TODO add more mappers and counting methods
    #TODO test hisat2 (low priority)
    #TODO add basecounter
#TODO make conda envs configurable (low priority)
    #TODO add version logging
#TODO add benchmarking to rules (low priority)

import pandas as pd

import resources.ownUtils as ou


config = ou.checkConfig(config)
source = srcdir("")

workdir: config["workdir"]
sampleSheet = pd.read_table(config["sampleSheet"], index_col=[0,1])
ou.checkSampleSheet(sampleSheet)


onstart:
    shell("echo Output directory: $(pwd)")

onsuccess:
    print("\n\nPIPELINE COMPLETED SUCCESSFULLY\n")
    shell("echo Output directory: $(pwd)")
    print("\n")

onerror:
    print("\n\nPIPELINE FAILED\n")
    print("Potential reasons for failure:")
    print("- faulty config file (see above error message)")
    print("- faulty sample sheet")
    print("- missing inputs")
    print("- mismatching MD5sums for inputs (see below)")
    print("MD5sum checks for inputs:")
    shell("cat .md5_check/*.log")
    print("\n\nPIPELINE FAILED\n")


rule all:
    input:
        ou.determineOutput(config, sampleSheet)


include: "rules/md5.smk"
include: "rules/fastqc.smk"
include: "rules/merge_fastq.smk"
include: "rules/cutadapt.smk"
include: "rules/star.smk"
include: "rules/bam_index.smk"
include: "rules/htseq-count.smk"
include: "rules/merge_counts.smk"
include: "rules/count_metrics.smk"
include: "rules/bamstats.smk"
include: "rules/hisat2.smk"
include: "rules/featurecounts.smk"
include: "rules/varscan.smk"
include: "rules/vcf_index.smk"


"""
output structure:
raw_metrics/
    {fastqc output}
merged/
    {sample}_merged.fastq
cleaned/
    metrics/
        {fastqc output}
    {sample}_cleaned.fastq
{mapper}/
    metrics/{sample}
        bamstats.json
        bamstat.summary.json
    {sample}/
        {sample}_{mapper}.bam
        {sample}_{mapper}.bam.bai
expression_measures_{mapper}/
    {type}/
        metrics/
            -TBD-
        {sample}/
            {sample}.fragements_per_gene
        all_samples.fragements_per_gene
variantcalling_{mapper}/
    {variantcaller}/
        {sample}/
            metrics/
            {sample}.vcf.gz
            {sample}.vcf.gz.tbi
"""
