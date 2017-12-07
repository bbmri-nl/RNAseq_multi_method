rule sickle_pe:
    input:
        r1="merged/{sample}_merged_1.fastq.gz",
        r2="merged/{sample}_merged_2.fastq.gz"
    output:
        r1="trimmed/{sample}_trimmed_1.fastq.gz",
        r2="trimmed/{sample}_trimmed_2.fastq.gz",
        rs="trimmed/{sample}_trimmed_s.fastq.gz"
    params:
        qual_type=config["sickle"]["qual_type"],
        extra=config["sickle"]["params"]
    log:
        "logs/sickle_pe/{sample}.log"
    wrapper:
        "0.17.4/bio/sickle/pe"

rule sickle_se:
    input:
        "merged/{sample}_merged.fastq.gz"
    output:
        "trimmed/{sample}_trimmed.fastq.gz"
    params:
        qual_type=config["sickle"]["qual_type"],
        extra=config["sickle"]["params"]
    log:
        "logs/sickle_se/{sample}.log"
    wrapper:
        "0.17.4/bio/sickle/se"
