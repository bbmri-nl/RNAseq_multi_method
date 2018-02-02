rule haplotypecaller:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.recal.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.recal.bai"
    output:
        vcf="variantcalling_{mapper}/haplotypecaller/{sample}/{sample}.vcf.gz",
        tbi="variantcalling_{mapper}/haplotypecaller/{sample}/{sample}.vcf.gz.tbi"
    resources:
        mem=lambda wildcards, attempt: attempt * 8
    log: ".logs/haplotypecaller/{sample}_{mapper}.log"
    params:
        gatk_path=config["bam_processing"]["gatk_path"],
        fasta=config["reference"]["fasta"],
        dbsnp=config["reference"]["dbsnp"],
        extra=config["variantcalling"]["haplotypecaller"]["params"]
    shell:
        "java -jar {params.gatk_path} "
        "-T HaplotypeCaller "
        "{params.extra} "
        "-R {params.fasta} "
        "-I {input.bam} "
        "--dontUseSoftClippedBases "
        "-o {output.vcf} "
        "--dbsnp {params.dbsnp} "
        "2> {log}"
