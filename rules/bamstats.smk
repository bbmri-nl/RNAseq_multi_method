rule bamstats:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "{mapper}/metrics/{sample}/bamstats.json",
        "{mapper}/metrics/{sample}/bamstats.summary.json"
    log:
        ".logs/bamstats/{mapper}_{sample}.log"
    resources:
        mem=lambda wildcards, attempt: attempt * 9
    shell:
        "module load biopet\n"
        "biopet tool bamstats -o {wildcards.mapper}/metrics/{wildcards.sample} "
        "--bam {input} > {log}\n"
        "module unload biopet"
