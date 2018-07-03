def getCentrifugeInputArg(wildcards):
    """
    This function generates the input arguments for salmon.
    """
    inputs = ou.getFilePerSample([wildcards.sample], sampleSheet,
        "centrifuge_{mapper}/{sample}/input/unmapped.fq",
        "centrifuge_{mapper}/{sample}/input/unmapped_{group}.fq",
        mapper=wildcards.mapper)
    if ou.isSingleEnd(wildcards.sample, sampleSheet):
        return "-U {input}".format(input=inputs[0])
    else:
        return "-1 {input1} -2 {input2}".format(input1=inputs[0],
            input2=inputs[1])


rule centrifuge:
    input:
        lambda w: ou.getFilePerSample([w.sample], sampleSheet,
            "centrifuge_{mapper}/{sample}/input/unmapped.fq",
            "centrifuge_{mapper}/{sample}/input/unmapped_{group}.fq",
            mapper=w.mapper)
    output:
        metrics="centrifuge_{mapper}/{sample}/{sample}_centrifuge.met",
        report="centrifuge_{mapper}/{sample}/{sample}_centrifuge.report",
        out="centrifuge_{mapper}/{sample}/{sample}_centrifuge.gz"
    params:
        extra=config["centrifuge"]["params"],
        index=config["centrifuge"]["index"],
        inputArgs=getCentrifugeInputArg
    threads: config["centrifuge"]["threads"]
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    log: ".logs/centrifuge/{sample}.log"
    conda: "../envs/centrifuge.yml"
    shell:
        "centrifuge {params.extra} "
        "--met-file {output.metrics} "
        "--threads {threads} "
        "-x {params.index} "
        "{params.inputArgs} "
        "--report-file {output.report} "
        "2> {log} | gzip -c > {output.out}"


rule getunmapped_pe_R1:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        temp("centrifuge_{mapper}/{sample}/input/unmapped_1.sam")
    threads: 4
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "samtools view -@ {threads} -h -f 4 -F 264 {input} > {output}"

rule getunmapped_pe_R2:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        temp("centrifuge_{mapper}/{sample}/input/unmapped_2.sam")
    threads: 4
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "samtools view -@ {threads} -h -f 8 -F 260 {input} > {output}"

rule getunmapped_pe_R1R2:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        temp("centrifuge_{mapper}/{sample}/input/unmapped_both.sam")
    threads: 4
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "samtools view -@ {threads} -h -f 12 -F 256 {input} > {output}"

rule getunmapped_pe_merge:
    input:
        "centrifuge_{mapper}/{sample}/input/unmapped_both.sam",
        "centrifuge_{mapper}/{sample}/input/unmapped_2.sam",
        "centrifuge_{mapper}/{sample}/input/unmapped_1.sam"
    output:
        temp("centrifuge_{mapper}/{sample}/input/unmapped_all.sam")
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "samtools merge {output} {input}"

rule getunmapped_pe_sort:
    input:
        "centrifuge_{mapper}/{sample}/input/unmapped_all.sam"
    output:
        temp("centrifuge_{mapper}/{sample}/input/unmapped_pe.bam")
    threads: 4
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "samtools sort -@ {threads} "
        "-n "
        "-o {output} "
        "-T centrifuge_{wildcards.mapper}/{wildcards.sample}/tmp "
        "{input}"

rule getunmapped_pe_fastq:
    input:
        "centrifuge_{mapper}/{sample}/input/unmapped_pe.bam"
    output:
        r1="centrifuge_{mapper}/{sample}/input/unmapped_1.fq",
        r2="centrifuge_{mapper}/{sample}/input/unmapped_2.fq"
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "bamToFastq -i {input} "
        "-fq {output.r1} "
        "-fq2 {output.r2}"

rule getunmapped_se_bam:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        temp("centrifuge_{mapper}/{sample}/input/unmapped_se.bam")
    threads: 4
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "samtools view -b -@ {threads} -h -f 4 {input} > {output}"

rule getunmapped_se_fastq:
    input:
        "centrifuge_{mapper}/{sample}/input/unmapped_se.bam"
    output:
        "centrifuge_{mapper}/{sample}/input/unmapped.fq"
    conda:
        "../envs/samtools.yml"
    resources:
        mem=lambda wildcards, attempt: attempt * 5
    shell:
        "bamToFastq -i {input} "
        "-fq {output} "
