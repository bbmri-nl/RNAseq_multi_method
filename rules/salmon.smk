def getSalmonInputArg(wildcards):
    """
    This function generates the input arguments for salmon.
    """
    inputs = ou.getFilePerSample([wildcards.sample], sampleSheet,
        "merged/{sample}_merged.fastq.gz",
        "merged/{sample}_merged_{group}.fastq.gz")
    if ou.isSingleEnd(wildcards.sample, sampleSheet):
        return "-r {input}".format(input=inputs[0])
    else:
        return "-1 {input1} -2 {input2}".format(input1=inputs[0],
            input2=inputs[1])


rule salmon:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        "expression_measures_without_alignment/salmon/{sample}/{sample}.tsv"
    params:
        index=config["counting"]["salmon"]["index"],
        extra=config["counting"]["salmon"]["params"],
        inputArgs=getSalmonInputArg
    threads: config["counting"]["salmon"]["threads"]
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    log: ".logs/salmon/{sample}.log"
    conda: "../envs/salmon.yml"
    shell:
        "salmon quant -p {threads} {params.extra} "
        "-l A "
        "-i {params.index} "
        "{params.inputArgs} "
        "-o expression_measures_without_alignment/salmon/{wildcards.sample}/salmon_out "
        "2> {log} && "
        "echo -e 'feature\\tTPM' > {output} && "
        "awk 'NR>2 {{print $1 \"\\t\" $4}}' expression_measures_without_alignment/salmon/{wildcards.sample}/salmon_out/quant.sf >> {output}"


# This doesn't work because mapping is done to genome
# rule salmon_a:
#     input:
#         bam="{mapper}/{sample}/{sample}_{mapper}.bam",
#         bai="{mapper}/{sample}/{sample}_{mapper}.bam.bai"
#     output:
#         "expression_measures_{mapper}/salmon_a/{sample}/{sample}.tsv"
#     params:
#         index=config["counting"]["salmon_a"]["index"],
#         extra=config["counting"]["salmon_a"]["params"]
#     threads: config["counting"]["salmon_a"]["threads"]
#     resources:
#         mem=lambda wildcards, attempt: attempt * 5
#     log: ".logs/salmon_a/{mapper}_{sample}.log"
#     conda: "../envs/salmon.yml"
#     shell:
#         "salmon quant -p {threads} "
#         "-l A "
#         "-i {params.index} " #should be fasta file of transcriptome, instead of index
#         "-a {input.bam} "
#         "-o expression_measures_{wildcards.mapper}/salmon_a/{wildcards.sample}/salmon_out "
#         "2> {log} && "
#         "echo -e 'feature\\tTPM' > {output} && "
#         "awk 'NR>2 {{print $1 \"\\t\" $4}}' expression_measures_{wildcards.mapper}/salmon_a/{wildcards.sample}/salmon_out/quant.sf >> {output}"
