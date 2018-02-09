ruleorder: haplotypecaller > vcf_index

rule haplotypecaller:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.recal.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.recal.bai"
    output:
        vcf="variantcalling_{mapper}/haplotypecaller/{sample}/{sample}.vcf.gz",
        tbi="variantcalling_{mapper}/haplotypecaller/{sample}/{sample}.vcf.gz.tbi",
        vcf_f="variantcalling_{mapper}/haplotypecaller/{sample}/{sample}.filtered.vcf.gz",
        tbi_f="variantcalling_{mapper}/haplotypecaller/{sample}/{sample}.filtered.vcf.gz.tbi"
    resources:
        mem=lambda wildcards, attempt: attempt * 16
    log: ".logs/haplotypecaller/{sample}_{mapper}.log"
    params:
        gatk_path=config["gatk"]["jar_path"],
        fasta=config["reference"]["fasta"],
        dbsnp=config["reference"]["dbsnp"],
        extra=config["variantcalling"]["haplotypecaller"]["params"],
        filter_extra=config["variantcalling"]["haplotypecaller"]["filter_params"]
    shell:
        "java -jar {params.gatk_path} "
        "-T HaplotypeCaller "
        "{params.extra} "
        "-R {params.fasta} "
        "-I {input.bam} "
        "-o {output.vcf} "
        "--dbsnp {params.dbsnp} "
        "2> {log} && "
        "java -jar {params.gatk_path} "
        "-T VariantFiltration "
        "{params.filter_extra} "
        "-R {params.fasta} "
        "-V {output.vcf} "
        "-o {output.vcf_f} "
        "2>> {log}"
