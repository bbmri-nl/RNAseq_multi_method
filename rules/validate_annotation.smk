rule validate_annotation:
    input:
        fasta=config["reference"]["fasta"],
        gtf=config["reference"]["gff"],
        refflat=config["reference"]["refflat"]
    output:
        touch(".validate_annotation/OK")
    priority: 100
    params:
        vaildateannotation_jar=config["validateannotation_jar"]
    resources:
        mem=lambda wildcards, attempt: attempt * 16
    log:
        ".logs/validate_annotation.log"
    shell:
        "java -jar {params.vaildateannotation_jar} "
        "-r {input.refflat} "
        "-g {input.gtf} "
        "-R {input.fasta} "
        "2> {log}"
