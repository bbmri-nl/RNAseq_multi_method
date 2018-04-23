rule htseq_count:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.mdup.bam"
    output:
        "expression_measures_{mapper}/htseq-count/{sample}/{sample}.tsv"
    params:
        gff=config["reference"]["gff"],
        stranded=config["stranded"],
        idField=config["counting"]["htseq-count"]["id_field"],
        extra=config["counting"]["htseq-count"]["params"]
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log:
        ".logs/htseq_count/{mapper}/{sample}.log"
    conda: "../envs/htseq.yml"
    shell:
        "htseq-count -f bam -r pos -i {params.idField} "
        "-s {params.stranded} {params.extra} {input} "
        "{params.gff} > {output} 2> {log} && "
        "sed -i '1s/^/feature\\tcounts\\n/' {output}"
