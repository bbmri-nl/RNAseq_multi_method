rule merge_pe:
    input:
        lambda w: ou.get_fastq(w, sampleSheet)
    output:
        "merged/{sample}_merged_{group}.fastq.gz",
    shell:
        "cat {input} > {output}"

rule merge_se:
    input:
        lambda w: ou.get_fastq(w, sampleSheet)
    output:
        "merged/{sample}_merged.fastq.gz",
    shell:
        "cat {input} > {output}"
