def getProperStrandPicard(w):
    dic =  {"no": "NONE", "yes": "FIRST_READ_TRANSCRIPTION_STRAND",
    "reverse": "SECOND_READ_TRANSCRIPTION_STRAND"}
    return dic[config["stranded"]]

rule rnaseq_stats:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.bam.bai"
    output:
        met="{mapper}/metrics/{sample}/rnaseq_stats.rna_metrics",
        pdf="{mapper}/metrics/{sample}/rnaseq_stats.pdf"
    resources:
        mem=lambda wildcards, attempt: attempt * 16
    log: ".logs/rnaseq_stats/{sample}_{mapper}.log"
    params:
        picard_path=config["picard_path"],
        refflat=config["reference"]["refflat"],
        strand=getProperStrandPicard
    conda: "../envs/R.yml"
    shell:
        "java -jar {params.picard_path} CollectRnaSeqMetrics "
        "TMP_DIR={wildcards.mapper}/metrics/{wildcards.sample}/rnaseq_stats/tmp "
        "INPUT={input.bam} "
        "OUTPUT={output.met} "
        "REF_FLAT={params.refflat} "
        "CHART_OUTPUT={output.pdf} "
        "STRAND_SPECIFICITY={params.strand}"
