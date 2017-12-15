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
        measureVars="counts"
    script: "../scripts/merge_counts.R"
