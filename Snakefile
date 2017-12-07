import pandas as pd


import ownUtils as ou


workdir: config["workdir"]
samples = pd.read_table(config["sampleSheet"], index_col=0)


rule all:
    input:
        ou.determineOutput(config, samples)

onsuccess:
    print("Generating MD5 checksums.")
    shell("md5sum ./* > md5")


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
    raw_files.md5
    -TBD-
merged/
    {sample}_merged.fastq
cleaned/
    metrics/
        -TBD-
    {sample}_cleaned.fastq
{mapper}/
    metrics/
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
            {sample}.fragements_per_gene.md5
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
