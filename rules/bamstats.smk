rule bamstats:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.mdup.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.mdup.bai"
    output:
        "{mapper}/metrics/{sample}/bamstats.json",
        "{mapper}/metrics/{sample}/bamstats.summary.json"
    params:
        extra=config["bamstats"]["params"]
    log:
        ".logs/bamstats/{mapper}_{sample}.log"
    resources:
        mem=lambda wildcards, attempt: attempt * 16
    shell:
        "module load biopet && "
        "biopet tool bamstats -o {wildcards.mapper}/metrics/{wildcards.sample} "
        "--bam {input.bam} {params.extra} > {log} && "
        "module unload biopet"
