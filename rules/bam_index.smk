rule bam_index:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "{mapper}/{sample}/{sample}_{mapper}.bam.bai"
    log:
        "logs/bam_index/{sample}_{mapper}.log"
    conda:
        "../envs/samtools.yml"
    shell:
        "samtools index {input} > {log}"
