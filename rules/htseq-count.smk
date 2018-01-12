rule htseq_count:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "expression_measures_{mapper}/htseq-count/{sample}/{sample}.tsv"
    params:
        gff=config["counting"]["htseq-count"]["annotation_gff"],
        stranded=config["counting"]["htseq-count"]["stranded"],
        idField=config["counting"]["htseq-count"]["id_field"],
        extra=config["counting"]["htseq-count"]["params"]
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    log:
        ".logs/htseq_count/{mapper}/{sample}.log"
    conda: "../envs/htseq.yml"
    shell:
        "htseq-count -f bam -r pos -i {params.idField} "
        "-s {params.stranded} {params.extra} {input} "
        "{params.gff} > {output} 2> {log} && "
        "sed -i '1s/^/feature\\tcounts\\n/' {output}"
