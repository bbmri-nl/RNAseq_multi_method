rule htseq_fpg:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "expression_measures_{mapper}/fragments_per_gene/{sample}/{sample}.fragments_per_gene"
    params:
        gff=config["counting"]["fragments_per_gene"]["annotation_gff"],
        stranded=config["counting"]["fragments_per_gene"]["stranded"],
        idField=config["counting"]["fragments_per_gene"]["id_field"],
        extra=config["counting"]["fragments_per_gene"]["params"]
    log:
        "logs/htseq_fpg/{mapper}/{sample}.log"
    conda: "../envs/htseq.yml"
    shell:
        "htseq-count -f bam -r pos -i {params.idField} "
        "-s {params.stranded} {params.extra} {input} "
        "{params.gff} > {output} 2> {log} && "
        "sed -i '1s/^/feature\\tcounts\\n/' {output}"


rule htseq_fpe:
    input:
        "{mapper}/{sample}/{sample}_{mapper}.bam"
    output:
        "expression_measures_{mapper}/fragments_per_exon/{sample}/{sample}.fragments_per_exon"
    params:
        gff=config["counting"]["fragments_per_exon"]["annotation_gff"],
        stranded=config["counting"]["fragments_per_exon"]["stranded"],
        idField=config["counting"]["fragments_per_exon"]["id_field"],
        extra=config["counting"]["fragments_per_exon"]["params"]
    log:
        "logs/htseq_fpe/{mapper}/{sample}.log"
    conda: "../envs/htseq.yml"
    shell:
        "htseq-count -f bam -r pos -i {params.idField} "
        "-s {params.stranded} {params.extra} {input} "
        "{params.gff} > {output} 2> {log} && "
        "sed -i '1s/^/feature\\tcounts\\n/' {output}"

#fragements_per_exon
