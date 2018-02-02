def getHisatInputArg(wildcards):
    """
    This function generates the input arguments for hisat2.
    """
    inputs = ou.getFilePerSample([wildcards.sample], sampleSheet,
        "merged/{sample}_merged.fastq.gz",
        "merged/{sample}_merged_{group}.fastq.gz")
    if ou.isSingleEnd(wildcards.sample, sampleSheet):
        return "-U {input}".format(input=inputs[0])
    else:
        return "-1 {input1} -2 {input2}".format(input1=inputs[0],
            input2=inputs[1])


rule hisat2:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        "hisat2/{sample}/{sample}_hisat2.bam"
    params:
        index=config["mappers"]["hisat2"]["index"],
        extra=config["mappers"]["hisat2"]["params"],
        threads=config["mappers"]["hisat2"]["threads"],
        inputArgs=getHisatInputArg
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    log: ".logs/hisat2/{sample}.log"
    threads: config["mappers"]["hisat2"]["threads"] * 2
    conda: "../envs/hisat2.yml"
    shell:
        "hisat2 {params.extra} "
        "-p {params.threads} "
        "-x {params.index} "
        "{params.inputArgs} "
        "2> {log} | "
        "samtools sort -@ {params.threads} "
        "-o {output} "
        "-T hisat2/{wildcards.sample}/tmp"
