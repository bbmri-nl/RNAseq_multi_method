#TODO add handeling of phred+64 (cutadapt, split_n_cigar_reads)
#TODO Add GATK best practises variantcalling
    #TODO add variant filtration
#TODO adjust bamstats/basecounter rules so it doesn't need to load the
    # biopet module (lwo priority; wait for jar releases)
#TODO make conda envs configurable (low priority)
#TODO add benchmarking to rules? (low priority)

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
    shell("echo Output directory: $(pwd)")
    print("\n")


rule all:
    input:
        ou.determineOutput(config, sampleSheet)

ruleorder: haplotypecaller > vcf_index

include: "rules/md5.smk"
include: "rules/merge_fastq.smk"
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
include: "rules/basecounter.smk"
include: "rules/qc.smk"
include: "rules/markduplicates.smk"
include: "rules/split_n_cigar_reads.smk"
include: "rules/baserecalibrator.smk"
include: "rules/printreads.smk"
include: "rules/haplotypecaller.smk"


"""
output structure:
QC/
    {sample}/
        {lane}/
            metrics/
                {fastqc output}
            {sample}_{lane}{group}.fastq.gz
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
            {sample}.tsv
        all_samples.tsv
variantcalling_{mapper}/
    {variantcaller}/
        {sample}/
            metrics/
            {sample}.vcf.gz
            {sample}.vcf.gz.tbi
"""
