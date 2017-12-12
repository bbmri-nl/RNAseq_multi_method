rule cutadapt_pe:
    input:
        lambda w: ou.getFastq(w, sampleSheet)
    output:
        fastq1="cleaned/{sample}_{lane}_cleaned_1.fastq.gz",
        fastq2="cleaned/{sample}_{lane}_cleaned_2.fastq.gz",
        qc="cleaned/{sample}_{lane}.qc.txt"
    params:
        adaptors=ou.adaptersAsParams(config),
        qual=config["cutadapt"]["quality_threshold"],
        minlen=config["cutadapt"]["minimum_readlength"],
        extra=config["cutadapt"]["params"]
    threads: config["cutadapt"]["threads"]
    conda: "../envs/cutadapt.yml"
    log:
        "logs/cutadapt_pe/{sample}_{lane}.log"
    shell:
        "cutadapt {params.extra} "
        "-q {params.qual},{params.qual} "
        "-m {params.minlen} "
        "-j {threads} "
        "{params.adaptors} "
        "-o {output.fastq1} "
        "-p {output.fastq2} "
        "{input} "
        "> {output.qc} 2> {log}"


rule cutadapt_se:
    input:
        lambda w: ou.getFastq(w, sampleSheet)
    output:
        fastq="cleaned/{sample}_{lane}_cleaned.fastq.gz",
        qc="cleaned/{sample}_{lane}.qc.txt"
    params:
        adaptors=ou.adaptersAsParams(config),
        qual=config["cutadapt"]["quality_threshold"],
        minlen=config["cutadapt"]["minimum_readlength"],
        extra=config["cutadapt"]["params"]
    threads: config["cutadapt"]["threads"]
    conda: "../envs/cutadapt.yml"
    log:
        "logs/cutadapt_se/{sample}_{lane}.log"
    shell:
        "cutadapt {params.extra} "
        "-q {params.qual},{params.qual} "
        "-m {params.minlen} "
        "-j {threads} "
        "{params.adaptors} "
        "-o {output.fastq} "
        "{input} "
        "> {output.qc} 2> {log}"
