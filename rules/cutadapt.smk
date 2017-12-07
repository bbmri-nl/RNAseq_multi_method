rule cutadapt_pe:
    input:
        "merged/{sample}_merged_1.fastq.gz",
        "merged/{sample}_merged_2.fastq.gz"
    output:
        fastq1="cleaned/{sample}_cleaned_1.fastq.gz",
        fastq2="cleaned/{sample}_cleaned_2.fastq.gz",
        qc="cleaned/{sample}.qc.txt"
    params:
        "-q {},{} {} {}".format(config["cutadapt"]["quality_threshold"],
            config["cutadapt"]["quality_threshold"],
            ou.adaptersAsParams(config), config["cutadapt"]["params"])
    log:
        "logs/cutadapt_pe/{sample}.log"
    wrapper:
        "0.17.4/bio/cutadapt/pe"

rule cutadapt_se:
    input:
        "merged/{sample}_merged.fastq.gz",
    output:
        fastq="cleaned/{sample}_cleaned.fastq.gz",
        qc="cleaned/{sample}.qc.txt"
    params:
        "-q {},{} {} {}".format(config["cutadapt"]["quality_threshold"],
            config["cutadapt"]["quality_threshold"],
            ou.adaptersAsParams(config), config["cutadapt"]["params"])
    log:
        "logs/cutadapt_se/{sample}.log"
    wrapper:
        "0.17.4/bio/cutadapt/se"
