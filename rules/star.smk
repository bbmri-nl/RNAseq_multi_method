#ruleorder: star_quant > star

rule star:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        "star/{sample}/{sample}_star.bam",
    params:
        index=config["mappers"]["star"]["index"],
        extra=config["mappers"]["star"]["params"]
    log:
        "logs/star/{sample}.log"
    threads: config["mappers"]["star"]["threads"]
    conda: "../envs/star.yml"
    shell:
        "STAR {params.extra} "
        "--runThreadN {threads} "
        "--genomeDir {params.index} "
        "--readFilesIn {input} "
        "--readFilesCommand zcat "
        "--outSAMtype BAM SortedByCoordinate "
        "--outFileNamePrefix star/{wildcards.sample}/ "
        "--outStd Log 2> {log} "
        "&& ln star/{wildcards.sample}/Aligned.sortedByCoord.out.bam {output}"



#rule star_quant:

#rule star_2pass:

#rule star_2pass_quant:
