rule varscan:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "variantcalling_{mapper}/varscan/{sample}/{sample}.vcf.gz"
    params:
        extra=config["variantcalling"]["varscan"]["params"],
        ref=config["reference"]["fasta"]
    log: ".logs/varscan/{sample}_{mapper}.log"
    conda: "../envs/varscan.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    shell:
        "echo {wildcards.sample} > "
        "variantcalling_{wildcards.mapper}/varscan/{wildcards.sample}/name.txt && "
        "samtools mpileup -f {params.ref} -d 10000000 -s -B {input} | "
        "varscan mpileup2cns --strand-filter 0 --output-vcf {params.extra} "
        "--vcf-sample-list variantcalling_{wildcards.mapper}/varscan/{wildcards.sample}/name.txt "
        " 2> {log}| "
        "bgzip -c > {output} && "
        "rm variantcalling_{wildcards.mapper}/varscan/{wildcards.sample}/name.txt"
