rule markduplicates:
    input:
        bam="{mapper}/{sample}/{sample}_{mapper}.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.bam.bai"
    output:
        bam="{mapper}/{sample}/{sample}_{mapper}.mdup.bam",
        bai="{mapper}/{sample}/{sample}_{mapper}.mdup.bai",
        metrics="{mapper}/{sample}/{sample}_{mapper}.mdup.metrics"
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log: ".logs/markduplicates/{sample}_{mapper}.log"
    params:
        picard_path=config["bam_processing"]["picard_path"],
        platform="illumina" #TODO make configurable
    shell:
        "java -jar {params.picard_path} MarkDuplicates "
        "INPUT={input.bam} "
        "OUTPUT={wildcards.mapper}/{wildcards.sample}/{wildcards.sample}_{wildcards.mapper}.tmp.bam "
        "METRICS_FILE={output.metrics} "
        "CREATE_INDEX=true "
        "VALIDATION_STRINGENCY=SILENT "
        "2> {log} && "
        "java -jar {params.picard_path} AddOrReplaceReadGroups "
        "I={wildcards.mapper}/{wildcards.sample}/{wildcards.sample}_{wildcards.mapper}.tmp.bam "
        "O={output.bam} "
        "CREATE_INDEX=true "
        "RGLB=unknown "
        "RGPU=unknown "
        "RGPL={params.platform} "
        "RGSM={wildcards.sample} "
        "2>> {log} && "
        "rm {wildcards.mapper}/{wildcards.sample}/{wildcards.sample}_{wildcards.mapper}.tmp.bam "
        "{wildcards.mapper}/{wildcards.sample}/{wildcards.sample}_{wildcards.mapper}.tmp.bai"
