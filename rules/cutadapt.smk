rule cutadapt_pe:
    input:
        "merged/{sample}_merged_1.fastq.gz",
        "merged/{sample}_merged_2.fastq.gz"
    output:
        fastq1="cleaned/{sample}_cleaned_1.fastq.gz",
        fastq2="cleaned/{sample}_cleaned_2.fastq.gz",
        qc="cleaned/{sample}.qc.txt"
    params:
        adaptors=ou.adaptersAsParams(config),
        qual=config["cutadapt"]["quality_threshold"],
        minlen=config["cutadapt"]["minimum_readlength"],
        extra=config["cutadapt"]["params"]
    threads: config["cutadapt"]["threads"]
    conda: "../envs/cutadapt.yml"
    log:
        "logs/cutadapt_pe/{sample}.log"
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
        "merged/{sample}_merged.fastq.gz",
    output:
        fastq="cleaned/{sample}_cleaned.fastq.gz",
        qc="cleaned/{sample}.qc.txt"
    params:
        adaptors=ou.adaptersAsParams(config),
        qual=config["cutadapt"]["quality_threshold"],
        minlen=config["cutadapt"]["minimum_readlength"],
        extra=config["cutadapt"]["params"]
    threads: config["cutadapt"]["threads"]
    conda: "../envs/cutadapt.yml"
    log:
        "logs/cutadapt_se/{sample}.log"
    shell:
        "cutadapt {params.extra} "
        "-q {params.qual},{params.qual} "
        "-m {params.minlen} "
        "-j {threads} "
        "{params.adaptors} "
        "-o {output.fastq} "
        "{input} "
        "> {output.qc} 2> {log}"
