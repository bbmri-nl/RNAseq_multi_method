rule count_metrics:
    input:
        "expression_measures_{mapper}/{type}/all_samples.{type}"
    output:
        sumTable="expression_measures_{mapper}/{type}/metrics/alignmentSummary.tsv",
        sumTablePerc="expression_measures_{mapper}/{type}/metrics/alignmentSummaryPercentages.tsv",
        report="expression_measures_{mapper}/{type}/metrics/metrics.html"
    conda: "../envs/R.yml"
    params:
        source=source,
        wd=config["workdir"]
    shell:
        "Rscript -e \"rmarkdown::render('{params.source}scripts/count_metrics.rmd', "
        "output_dir='expression_measures_{wildcards.mapper}/{wildcards.type}/metrics', "
        "intermediates_dir='expression_measures_{wildcards.mapper}/{wildcards.type}/metrics', "
        "knit_root_dir='{params.wd}', "
        "output_file='{output.report}', "
        "params=list(input = '{input}', sumTable='{output.sumTable}', "
        "sumTablePerc='{output.sumTablePerc}', type='{wildcards.type}')"
        ")\""
