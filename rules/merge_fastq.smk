rule merge_fastq_pe:
    input:
        lambda w: expand(
            "QC_pe/{sample}/{lane}/{sample}_{lane}_cleaned_{group}.fastq.gz",
            sample=w.sample, lane=ou.getLanesForSample(w.sample, sampleSheet),
            group=w.group)
    output:
        "merged/{sample}_merged_{group}.fastq.gz"
    resources:
        mem=lambda wildcards, attempt: attempt * 1
    params:
        lane=lambda w: ou.getLanesForSample(w.sample, sampleSheet)[0]
    conda: "../envs/seqtk.yml"
    shell:
        "if [ $( egrep -c Sanger "
        "< \"QC_pe/{wildcards.sample}/{params.lane}/phred_encoding.txt\" "
        ") -eq 1 ]; "
        "then phredBase=33; "
        "else phredBase=64; "
        "fi && "
        "cat {input} | seqtk seq -Q $phredBase -V | gzip > {output}"

rule merge_fastq_se:
    input:
        lambda w: expand(
            "QC_se/{sample}/{lane}/{sample}_{lane}_cleaned.fastq.gz",
            sample=w.sample, lane=ou.getLanesForSample(w.sample, sampleSheet))
    output:
        "merged/{sample}_merged.fastq.gz"
    resources:
        mem=lambda wildcards, attempt: attempt * 1
    params:
        lane=lambda w: ou.getLanesForSample(w.sample, sampleSheet)[0]
    conda: "../envs/seqtk.yml"
    shell:
        "if [ $( egrep -c Sanger "
        "< \"QC_se/{wildcards.sample}/{params.lane}/phred_encoding.txt\" "
        ") -eq 1 ]; "
        "then phredBase=33; "
        "else phredBase=64; "
        "fi && "
        "cat {input} | seqtk seq -Q $phredBase -V | gzip > {output}"
