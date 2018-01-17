def getProperColumn(w):
    dic =  {"no": "2", "yes": "3", "reverse": "4"}
    return dic[config["stranded"]]


if config["counting"]["star_quantmode"]["include"]:
    ruleorder: star_quant > star
    ruleorder: star2pass_quant > star2pass
else:
    ruleorder: star > star_quant
    ruleorder: star2pass > star2pass_quant


rule star:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        "star/{sample}/{sample}_star.bam"
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


rule star_quant:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        bam="star/{sample}/{sample}_star.bam",
        counts="expression_measures_star/star_quantmode/{sample}/{sample}.tsv"
    params:
        index=config["mappers"]["star"]["index"],
        extra=config["mappers"]["star"]["params"],
        countExtra=config["counting"]["star_quantmode"]["params"],
        col=getProperColumn
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log:
        ".logs/star/{sample}.log"
    threads: config["mappers"]["star"]["threads"]
    conda: "../envs/star.yml"
    shell:
        "STAR {params.extra} {params.countExtra} "
        "--quantMode GeneCounts "
        "--runThreadN {threads} "
        "--genomeDir {params.index} "
        "--readFilesIn {input} "
        "--readFilesCommand zcat "
        "--outSAMtype BAM SortedByCoordinate "
        "--outFileNamePrefix star/{wildcards.sample}/ "
        "--outStd Log 2> {log} "
        "&& ln star/{wildcards.sample}/Aligned.sortedByCoord.out.bam {output.bam} "
        "&& echo -e 'feature\\tcounts' > {output.counts} "
        "&& awk 'NR>2 {{print $1 \"\\t\" ${params.col}}}' star/{wildcards.sample}/ReadsPerGene.out.tab >> {output.counts}"


rule star2pass:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        "star2pass/{sample}/{sample}_star2pass.bam"
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


rule star2pass_quant:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "merged/{sample}_merged.fastq.gz",
            "merged/{sample}_merged_{group}.fastq.gz")
    output:
        bam="star2pass/{sample}/{sample}_star2pass.bam",
        counts="expression_measures_star2pass/star_quantmode/{sample}/{sample}.tsv"
    params:
        index=config["mappers"]["star2pass"]["index"],
        extra=config["mappers"]["star2pass"]["params"],
        countExtra=config["counting"]["star_quantmode"]["params"],
        col=getProperColumn
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log:
        ".logs/star2pass/{sample}.log"
    threads: config["mappers"]["star2pass"]["threads"]
    conda: "../envs/star.yml"
    shell:
        "STAR {params.extra} {params.countExtra} "
        "--quantMode GeneCounts "
        "--twopassMode Basic "
        "--runThreadN {threads} "
        "--genomeDir {params.index} "
        "--readFilesIn {input} "
        "--readFilesCommand zcat "
        "--outSAMtype BAM SortedByCoordinate "
        "--outFileNamePrefix star2pass/{wildcards.sample}/ "
        "--outStd Log 2> {log} "
        "&& ln star2pass/{wildcards.sample}/Aligned.sortedByCoord.out.bam {output.bam} "
        "&& echo -e 'feature\\tcounts' > {output.counts} "
        "&& awk 'NR>2 {{print $1 \"\\t\" ${params.col}}}' star2pass/{wildcards.sample}/ReadsPerGene.out.tab >> {output.counts}"
