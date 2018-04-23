rule split_n_cigar_reads:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.mdup.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.mdup.bai",
    output:
        bam=temp("{mapper}/{sample}/{sample}_{mapper}.split.bam"),
        bai=temp("{mapper}/{sample}/{sample}_{mapper}.split.bai")
    resources:
        mem=lambda wildcards, attempt: attempt * 12
    log: ".logs/split_n_cigar_reads/{sample}_{mapper}.log"
    params:
        gatk_path=config["gatk"]["jar_path"],
        fasta=config["reference"]["fasta"],
    shell:
        "java -Xmx4000m -jar {params.gatk_path} "
        "-T SplitNCigarReads "
        "-R {params.fasta} "
        "-I {input.bam} "
        "-o {output.bam} "
        "-rf ReassignOneMappingQuality "
        "-RMQF 255 "
        "-RMQT 60 "
        "-U ALLOW_N_CIGAR_READS 2> {log}"
