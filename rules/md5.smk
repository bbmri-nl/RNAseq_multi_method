rule md5:
    input:
        "{file}"
    output:
        "{file}.md5"
    shell:
        "md5sum {input} > {output}"


rule md5_check_raw:
    input:
        lambda w: ou.lookForInputFile(w, sampleSheet)
    output:
        touch(".md5_check/{file}.OK")
    params:
        md5=lambda w: ou.getMD5FromSampleSheet(w, sampleSheet)
    log:
        ".md5_check/{file}.log"
    shell:
        "echo \"{params.md5}  {input}\" | md5sum -c > {log}"
