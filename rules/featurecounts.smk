def pairedOrNot(wildcards):
    if ou.isSingleEnd(wildcards.sample, sampleSheet):
        return ""
    return "-p"


def getStrandedOption(x):
    if x == "yes":
        return "-s 1"
    if x == "reverse":
        return "-s 2"
    return ""


rule featurecounts:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "expression_measures_{mapper}/featurecounts/{sample}/{sample}.tsv"
    params:
        feature_type=config["counting"]["featurecounts"]["feature_type"],
        feature_group=config["counting"]["featurecounts"]["feature_group"],
        gff=config["reference"]["gff"],
        extra=config["counting"]["featurecounts"]["params"],
        stranded=getStrandedOption(config["stranded"]),
        paired=pairedOrNot
    conda: "../envs/featurecounts.yml"
    log: ".logs/featurecounts/{mapper}/{sample}.log"
    resources:
            mem=lambda wildcards, attempt: attempt * 3
    shell:
        "featureCounts {params.extra} "
        "{params.stranded} "
        "{params.paired} "
        "-t {params.feature_type} "
        "-g {params.feature_group} "
        "-a {params.gff} "
        "-o {output}.original "
        "{input} > {log} && "
        "echo -e 'feature\\tcounts' > {output} && "
        "awk 'NR>2 {{print $1 \"\\t\" $NF}}' {output}.original >> {output} && "
        "tail -n +3 {output}.original.summary >> {output}"
