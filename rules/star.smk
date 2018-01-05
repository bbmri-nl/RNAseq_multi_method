#ruleorder: star > star_quant

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
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log:
        ".logs/star/{sample}.log"
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
# In the quant mode output: $2 = unstranded, $3 = stranded, $4 = reverse
# name approriate (based on config) column "counts" so it will be used by
# merge_counts.

rule star2pass:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        "star2pass/{sample}/{sample}_star2pass.bam",
    params:
        index=config["mappers"]["star2pass"]["index"],
        extra=config["mappers"]["star2pass"]["params"]
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log:
        ".logs/star2pass/{sample}.log"
    threads: config["mappers"]["star2pass"]["threads"]
    conda: "../envs/star.yml"
    shell:
        "STAR {params.extra} "
        "--twopassMode Basic "
        "--runThreadN {threads} "
        "--genomeDir {params.index} "
        "--readFilesIn {input} "
        "--readFilesCommand zcat "
        "--outSAMtype BAM SortedByCoordinate "
        "--outFileNamePrefix star2pass/{wildcards.sample}/ "
        "--outStd Log 2> {log} "
        "&& ln star2pass/{wildcards.sample}/Aligned.sortedByCoord.out.bam {output}"

#rule star2pass_quant:
