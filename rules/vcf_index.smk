rule vcf_index:
    input:
        "variantcalling_{mapper}/{tool}/{sample}/{sample}.vcf.gz"
    output:
        "variantcalling_{mapper}/{tool}/{sample}/{sample}.vcf.gz.tbi"
    conda: "../envs/varscan.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    log: ".logs/vcf_index/{sample}_{mapper}_{tool}.log"
    shell:
        "tabix -p vcf {input} > {log}"
