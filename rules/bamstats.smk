rule bamstats:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "{mapper}/metrics/{sample}/bamstats.json",
        "{mapper}/metrics/{sample}/bamstats.summary.json"
    params:
        extra=config["bamstats"]["params"]
    log:
        ".logs/bamstats/{mapper}_{sample}.log"
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    shell:
        "module load biopet && "
        "biopet tool bamstats -o {wildcards.mapper}/metrics/{wildcards.sample} "
        "--bam {input} {params.extra} > {log} && "
        "module unload biopet"
