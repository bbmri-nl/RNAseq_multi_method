rule split_n_cigar_reads:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.mdup.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.mdup.bai"
    output:
        bam="{mapper}/{sample}/{sample}_{mapper}.split.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.split.bai"
    resources:
        mem=lambda wildcards, attempt: attempt * 4
    log: ".logs/split_n_cigar_reads/{sample}_{mapper}.log"
    params:
        gatk_path=config["bam_processing"]["gatk_path"],
        fasta=config["reference"]["fasta"]
    shell:
        "java -Xmx1500m -jar {params.gatk_path} "
        "-T SplitNCigarReads "
        "-R {params.fasta} "
        "-I {input.bam} "
        "-o {output.bam} "
        "-rf ReassignOneMappingQuality "
        "-RMQF 255 "
        "-RMQT 60 "
        "-U ALLOW_N_CIGAR_READS 2> {log}"
