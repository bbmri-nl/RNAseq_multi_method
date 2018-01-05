rule bam_index:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "{mapper}/{sample}/{sample}_{mapper}.bam.bai"
    log:
        ".logs/bam_index/{sample}_{mapper}.log"
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    shell:
        "samtools index {input} > {log}"
