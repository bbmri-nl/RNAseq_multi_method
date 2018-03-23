def getValidateFastqInputs(wildcards, sampleSheet):
    R1 = ou.lookForInputFile(wildcards, sampleSheet)
    R2 = ou.getR2forR1(R1, sampleSheet)
    if R2 != None:
        return [R1, R2]
    else:
        return [R1]


def getValidateFastqInputsArgs(inputs):
    if len(inputs) == 2:
        return "-i {} -j {}".format(inputs[0], inputs[1])
    return "-i {}".format(inputs[0])


rule validate_fastq:
    input:
        lambda w: getValidateFastqInputs(w, sampleSheet)
    output:
        touch(".fastq_check/{file}.OK")
    params:
        validatefastq_jar=config["validatefastq_jar"],
        inputArgs=lambda wildcards, input: getValidateFastqInputsArgs(input)
    resources:
        mem=lambda wildcards, attempt: attempt * 3
    log:
        ".validate_fastq/{file}.log"
    shell:
        "java -jar {params.validatefastq_jar} {params.inputArgs} 2> {log} && "
        "[ $(egrep -c ERROR {log}) -eq 0 ]"
