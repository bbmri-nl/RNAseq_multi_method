def determineCountsColumn(w):
    if w.type in ["salmon", "salmon_a"]:
        return "TPM"
    return "counts"


rule merge_counts:
    input:
        lambda w: expand(
            "expression_measures_{mapper}/{type}/{sample}/{sample}.tsv",
            mapper=w.mapper, type=w.type,
            sample=sampleSheet.index.levels[0].tolist())
    output:
        "expression_measures_{mapper}/{type}/all_samples.tsv"
    conda: "../envs/R.yml"
    params:
        source=source,
        countsColumn=determineCountsColumn
    resources:
        mem=lambda wildcards, attempt: attempt * 10
    log: ".logs/merge_counts/{mapper}_{type}.log"
    shell:
        "Rscript {params.source}scripts/merge_counts.R "
        "feature {params.countsColumn} {output} "
        "{input} > {log}"
