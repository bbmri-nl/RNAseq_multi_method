rule md5:
    input:
        "{file}"
    output:
        "{file}.md5"
    priority: 10
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    shell:
        "md5sum $(pwd)/{input} > {output}"


rule md5_check_raw:
    input:
        lambda w: ou.lookForInputFile(w, sampleSheet)
    output:
        touch(".md5_check/{file}.OK")
    priority: 50
    params:
        md5=lambda w: ou.getMD5FromSampleSheet(w, sampleSheet)
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    log:
        ".md5_check/{file}.log"
    shell:
        "echo \"{params.md5}  {input}\" | md5sum -c > {log}"
