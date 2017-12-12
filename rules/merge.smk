rule merge_pe:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "cleaned/{sample}_{lane}_cleaned.fastq.gz",
            "cleaned/{sample}_{lane}_cleaned_{group}.fastq.gz",
            lane=ou.getLanesForSample(w.sample, sampleSheet))
    output:
        "merged/{sample}_merged_{group}.fastq.gz",
    shell:
        "cat {input} > {output}"

rule merge_se:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "cleaned/{sample}_{lane}_cleaned.fastq.gz",
            "cleaned/{sample}_{lane}_cleaned_{group}.fastq.gz",
            lane=ou.getLanesForSample(w.sample, sampleSheet))
    output:
        "merged/{sample}_merged.fastq.gz",
    shell:
        "cat {input} > {output}"
