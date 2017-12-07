import pandas as pd

import ownUtils as ou


ou.checkConfig(config)


workdir: config["workdir"]
sampleSheet = pd.read_table(config["sampleSheet"], index_col=0)


onstart:
    shell("echo Output directory: $(pwd)")

onerror:
    print("MD5sum checks for inputs: (one might have failed)")
    shell("cat .md5_check/*.log")


rule all:
    input:
        ou.determineOutput(config, sampleSheet)


include: "rules/md5.smk"
include: "rules/fastqc.smk"
include: "rules/merge.smk"
include: "rules/cutadapt.smk"


"""
Results should include:
- bam per sample per mapper
- counts per sample per mapper
- vcf per sample per mapper?
- merged fastq per sample

output structure:
md5
raw_metrics/
    {fastqc output}
merged/
    {sample}_merged.fastq
cleaned/
    metrics/
        {fastqc output}
    {sample}_cleaned.fastq
{mapper}/
    metrics/samples
        -TBD-
    {sample}/
        {sample}.bam
        {sample}.bam.bai
expression_measures_{mapper}/
    metrics/
        -TBD-
    {type}/
        {sample}/
            {sample}.fragements_per_gene
        merged.fragements_per_gene
{variantcaller}_{mapper}/
    metrics/ ?
    {sample}.{variantcaller}.vcf
    {sample}.{variantcaller}.vcf.md5
"""

"""
QC (fastqc)
merge fastq
cutadapt
QC (fastqc)
mappers
QC (rseqc?)
htseq count per mapper
other counts methods per mapper ? (featurecounts)
variantcallers per mapper ?
"""
