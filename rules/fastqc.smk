rule fastqc_raw:
    input:
        lambda w: ou.lookForInputFile(w, samples)
    output:
        html="raw_metrics/{file}_fastqc.html",
        zip="raw_metrics/{file}_fastqc.zip"
    params: ""
    log:
        "logs/fastqc_raw/{file}.log"
    wrapper:
        "0.17.4/bio/fastqc"

rule fastqc_processed:
    input:
        "{directory}/{file}"
    output:
        html="{directory}/metrics/{file}_fastqc.html",
        zip="{directory}/metrics/{file}_fastqc.zip"
    params: ""
    log:
        "logs/fastqc_clean/{file}.log"
    wrapper:
        "0.17.4/bio/fastqc"
