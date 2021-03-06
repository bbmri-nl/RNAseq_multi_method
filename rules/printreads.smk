rule printreads:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.split.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.split.bai",
        bqsr="{mapper}/{sample}/{sample}_{mapper}.bqsr.csv"
    output:
        bam=temp("{mapper}/{sample}/{sample}_{mapper}.recal.bam"),
        bai=temp("{mapper}/{sample}/{sample}_{mapper}.recal.bai")
    resources:
        mem=lambda wildcards, attempt: attempt * 12
    log: ".logs/apply_bqsr/{sample}_{mapper}.log"
    params:
        gatk_path=config["gatk"]["jar_path"],
        fasta=config["reference"]["fasta"]
    shell:
        "java -Xms4000m -jar {params.gatk_path} "
        "-T PrintReads "
        "-R {params.fasta} "
        "-I {input.bam} "
        "--useOriginalQualities "
        "-o {output.bam} "
        "-BQSR {input.bqsr} "
        "2> {log}"
