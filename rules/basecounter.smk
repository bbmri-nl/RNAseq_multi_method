def getBasecounterOutput(w):
    strand = {"no": "", "yes": "sense", "reverse": "antisense"}
    out = ("expression_measures_{mapper}/.basecounter/{sample}/"
        "{sample}.base.{type}{strand}.counts".format(mapper=w.mapper,
            sample=w.sample, type=w.type, strand=strand[config["stranded"]]))
    return out


rule basecounter:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.exon.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.exon.sense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.exon.antisense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.intron.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.intron.sense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.intron.antisense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.gene.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.gene.sense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.gene.antisense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.transcript.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.transcript.sense.counts",
        "expression_measures_{mapper}/.basecounter/{sample}/"
            "{sample}.base.transcript.antisense.counts"
    params:
        refflat=config["reference"]["refflat"]
    log: ".logs/basecounter/{mapper}_{sample}.log"
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    shell:
        "module load biopet && "
        "biopet tool basecounter -r {params.refflat} -b {input} "
        "-o expression_measures_{wildcards.mapper}/.basecounter/{wildcards.sample} "
        "-p {wildcards.sample} 2> {log} && "
        "module unload biopet"


rule basecounter_format:
    input:
        lambda w: getBasecounterOutput(w)
    output:
        "expression_measures_{mapper}/basecounter_{type}/{sample}/{sample}.tsv"
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    shell:
        "echo -e 'feature\\tcounts' > {output} && "
        "cat {input} >> {output}"
