rule baserecalibrator:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.split.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.split.bai"
    output:
        temp("{mapper}/{sample}/{sample}_{mapper}.bqsr.csv")
    resources:
        mem=lambda wildcards, attempt: attempt * 16
    log: ".logs/baserecalibrator/{sample}_{mapper}.log"
    params:
        gatk_path=config["gatk"]["jar_path"],
        fasta=config["reference"]["fasta"],
        dbsnp=config["reference"]["dbsnp"]
    shell:
        "java -Xms4000m -jar {params.gatk_path} "
        "-T BaseRecalibrator "
        "-R {params.fasta} "
        "-I {input.bam} "
        "--useOriginalQualities "
        "-o {output} "
        "--knownSites {params.dbsnp} "
        "2> {log}"
