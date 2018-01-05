rule merge_fastq_pe:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "cleaned/{sample}_{lane}_cleaned_{group}.fastq.gz",
            lane=ou.getLanesForSample(w.sample, sampleSheet),
            group=w.group)
    output:
        "merged/{sample}_merged_{group}.fastq.gz"
    resources:
        mem=lambda wildcards, attempt: attempt * 1
    shell:
        "cat {input} > {output}"

rule merge_fastq_se:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "cleaned/{sample}_{lane}_cleaned.fastq.gz",
            lane=ou.getLanesForSample(w.sample, sampleSheet))
    output:
        "merged/{sample}_merged.fastq.gz"
    resources:
        mem=lambda wildcards, attempt: attempt * 1
    shell:
        "cat {input} > {output}"
