rule qc_pe:
    input:
        lambda w: ou.getFastq(w, sampleSheet)
    output:
        raw_html_R1="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_raw_1.html",
        raw_html_R2="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_raw_2.html",
        raw_zip_R1="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_raw_1.zip",
        raw_zip_R2="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_raw_2.zip",
        clean_R1="QC_pe/{sample}/{lane}/{sample}_{lane}_cleaned_1.fastq.gz",
        clean_R2="QC_pe/{sample}/{lane}/{sample}_{lane}_cleaned_2.fastq.gz",
        clean_html_R1="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_cleaned_1.html",
        clean_html_R2="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_cleaned_2.html",
        clean_zip_R1="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_cleaned_1.zip",
        clean_zip_R2="QC_pe/{sample}/{lane}/metrics/{sample}_{lane}_cleaned_2.zip",
        qc_report="QC_pe/{sample}/{lane}/cutadapt_qc.txt",
        encoding=temp("QC_pe/{sample}/{lane}/phred_encoding.txt")
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    params:
        contaminant_file=config["QC"]["contaminants"],
        adapter_file=config["QC"]["adapters"],
        cutadapt_extra=config["QC"]["cutadapt_params"],
        quality_threshold=config["QC"]["quality_threshold"],
        minimum_length=config["QC"]["minimum_readlength"],
        extractadaptersfastqc_jar=config["QC"]["extractadaptersfastqc_jar"],
        java_extra="-Xmx1500m"
    threads: config["QC"]["threads"]
    wrapper: "file:{source}wrappers/QC-snakemake".format(source=source)


rule qc_se:
    input:
        lambda w: ou.getFastq(w, sampleSheet)
    output:
        raw_html_R1="QC_se/{sample}/{lane}/metrics/{sample}_{lane}_raw.html",
        raw_zip_R1="QC_se/{sample}/{lane}/metrics/{sample}_{lane}_raw.zip",
        clean_R1="QC_se/{sample}/{lane}/{sample}_{lane}_cleaned.fastq.gz",
        clean_html_R1="QC_se/{sample}/{lane}/metrics/{sample}_{lane}_cleaned.html",
        clean_zip_R1="QC_se/{sample}/{lane}/metrics/{sample}_{lane}_cleaned.zip",
        qc_report="QC_se/{sample}/{lane}/cutadapt_qc.txt",
        encoding=temp("QC_se/{sample}/{lane}/phred_encoding.txt")
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    params:
      contaminant_file=config["QC"]["contaminants"],
      adapter_file=config["QC"]["adapters"],
      cutadapt_extra=config["QC"]["cutadapt_params"],
      quality_threshold=config["QC"]["quality_threshold"],
      minimum_length=config["QC"]["minimum_readlength"],
      extractadaptersfastqc_jar=config["QC"]["extractadaptersfastqc_jar"],
      java_extra="-Xmx1500m"
    threads: config["QC"]["threads"]
    wrapper: "file:{source}wrappers/QC-snakemake".format(source=source)
