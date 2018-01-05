import pandas as pd

import resources.ownUtils as ou


config = ou.checkConfig(config)
source = srcdir("")

workdir: config["workdir"]
sampleSheet = pd.read_table(config["sampleSheet"], index_col=[0,1])


onstart:
    shell("echo Output directory: $(pwd)")

onerror:
    print("\n\nPIPELINE FAILED\n")
    print("Potential reasons for failure:")
    print("- faulty config file (see above error message)")
    print("- faulty sample sheet")
    print("- missing inputs")
    print("- Mismatching MD5sums for inputs")
    print("MD5sum checks for inputs:")
    shell("cat .md5_check/*.log")
    print("\n")


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


"""
Results should include:
- bam per sample per mapper
- counts per sample per mapper
- vcf per sample per mapper?
- merged fastq per sample

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
    metrics/samples
        -TBD-
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
{variantcaller}_{mapper}/
    metrics/ ?
    {sample}.{variantcaller}.vcf
    {sample}.{variantcaller}.vcf.md5
"""

"""
QC (fastqc)
cutadapt
QC (fastqc)
merge fastq
mappers
htseq count per mapper
other counts methods per mapper ? (featurecounts)
count metrics
variantcallers per mapper ?
"""
