rule merge_counts:
    input:
        lambda w: ou.getFilePerSample(sampleSheet.index.levels[0].tolist(),
            sampleSheet,
            "expression_measures_{mapper}/{type}/{sample}/{sample}.{type}",
            mapper=w.mapper, type=w.type)
    output:
        "expression_measures_{mapper}/{type}/all_samples.{type}"
    conda: "../envs/R.yml"
    params:
        idVars="feature",
        measureVars="counts",
        source=source
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log: ".logs/merge_counts/{mapper}_{type}.log"
    shell:
        "Rscript {params.source}scripts/merge_counts.R "
        "{params.idVars} {params.measureVars} {output} "
        "{input} > {log}"
