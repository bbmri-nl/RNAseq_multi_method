__author__ = "Davy Cats"
__copyright__ = "Copyright 2018, Davy Cats"
__email__ = "D.Cats@lumc.nl"
__license__ = "MIT"

from os import path

from snakemake.shell import shell

log = snakemake.log_fmt_shell(stdout=True, stderr=True)

"""
input:
    - R1
    ? R1
output:
    - raw_html_R1
    ? raw_html_R2
    - raw_zip_R1
    ? raw_zip_R2
    - clean_R1
    ? clean_R2
    - clean_html_R1
    ? clean_html_R2
    - clean_zip_R1
    ? clean_zip_R2
    - qc_report
    - encoding
"""


def basename_without_ext(file_path):
    """
    Returns basename of file path, without the file extension.
    """
    base = path.basename(file_path)
    split_ind = 2 if base.endswith(".gz") else 1
    base = ".".join(base.split(".")[:-split_ind])
    return base


# check input/output/params
n = len(snakemake.input)
if n == 2:
    R1 = snakemake.input[0]
    R2 = snakemake.input[1]
    for x in ["clean_R2", "clean_html_R2", "clean_zip_R2", "raw_zip_R2",
        "raw_html_R2"]:
        assert hasattr(snakemake.output, x), "Missing R2 output paths."
elif n == 1:
    R1 = snakemake.input[0]
else:
    assert False, "Input must be of length 1 or 2."
for x in ["clean_R1", "clean_html_R1", "clean_zip_R1", "raw_zip_R1",
        "raw_html_R1", "qc_report", "encoding"]:
    assert hasattr(snakemake.output, x), "Missing R1 output paths."
for x in ["java_extra", "cutadapt_extra", "quality_threshold",
    "minimum_length", "extractadaptersfastqc_jar"]:
    assert hasattr(snakemake.params, x), "Missing param fields."


# Run raw fastqc
output_dir_raw_fastqc_R1 = path.dirname(snakemake.output.raw_html_R1)
if n == 2:
    output_dir_raw_fastqc_R2 = path.dirname(snakemake.output.raw_html_R2)
    raw_output_base_R2 = basename_without_ext(R2)
    if snakemake.threads > 1:
        shell("{{ ( fastqc --quiet --outdir {output_dir_raw_fastqc_R1} {R1} && "
            "echo ok ) & "
            "( fastqc --quiet --outdir {output_dir_raw_fastqc_R2} {R2} && "
            "echo ok ) & }} "
            "| grep -c ok | (read n && ((n==2)))") #check if both succeeded
    else:
        shell("fastqc --quiet --outdir {output_dir_raw_fastqc_R1} {R1}")
        shell("fastqc --quiet --outdir {output_dir_raw_fastqc_R2} {R2}")
    # Get output as made by fastqc
    raw_html_path_R2 = path.join(output_dir_raw_fastqc_R2,
        raw_output_base_R2 + "_fastqc.html")
    raw_zip_path_R2 = path.join(output_dir_raw_fastqc_R2,
        raw_output_base_R2 + "_fastqc.zip")
    # Rename output to match given exptected output names
    if snakemake.output.raw_html_R2 != raw_html_path_R2:
        shell("mv {raw_html_path_R2} {snakemake.output.raw_html_R2}")
    if snakemake.output.raw_zip_R2 != raw_zip_path_R2:
        shell("mv {raw_zip_path_R2} {snakemake.output.raw_zip_R2}")
else:
    shell("fastqc --quiet --outdir {output_dir_raw_fastqc_R1} {R1}")
# Get output as made by fastqc
raw_output_base_R1 = basename_without_ext(R1)
raw_html_path_R1 = path.join(output_dir_raw_fastqc_R1,
    raw_output_base_R1 + "_fastqc.html")
raw_zip_path_R1 = path.join(output_dir_raw_fastqc_R1,
    raw_output_base_R1 + "_fastqc.zip")
# Rename output to match given exptected output names
if snakemake.output.raw_html_R1 != raw_html_path_R1:
    shell("mv {raw_html_path_R1} {snakemake.output.raw_html_R1}")
if snakemake.output.raw_zip_R1 != raw_zip_path_R1:
    shell("mv {raw_zip_path_R1} {snakemake.output.raw_zip_R1}")


# Run extractadaptersfastqc
cutadapt_output_dir_R1 = path.dirname(snakemake.output.clean_R1)
R1_data_path = path.join(output_dir_raw_fastqc_R1, raw_output_base_R1 +
    "_fastqc.txt")
R1_contam_path = path.join(output_dir_raw_fastqc_R1, raw_output_base_R1 +
    ".contams")
R1_adapter_path = path.join(output_dir_raw_fastqc_R1, raw_output_base_R1 +
    ".adapters")
shell("unzip -p {snakemake.output.raw_zip_R1} "
    "{raw_output_base_R1}_fastqc/fastqc_data.txt > "
    "{R1_data_path}")
shell("grep -Po '(?<=Encoding\t).*' < {R1_data_path} "
    "> {snakemake.output.encoding}")
if n == 2:
    R2_data_path = path.join(output_dir_raw_fastqc_R2, raw_output_base_R2 +
        "_fastqc.txt")
    R2_contam_path = path.join(output_dir_raw_fastqc_R2, raw_output_base_R2 +
        ".contams")
    R2_adapter_path = path.join(output_dir_raw_fastqc_R2, raw_output_base_R2 +
        ".adapters")
    shell("unzip -p {snakemake.output.raw_zip_R2} "
        "{raw_output_base_R2}_fastqc/fastqc_data.txt > "
        "{R2_data_path}")
    cutadapt_output_dir_R1 = path.dirname(snakemake.output.clean_R2)
    if snakemake.threads > 1:
        shell("{{ ( java {snakemake.params.java_extra} "
            "-jar {snakemake.params.extractadaptersfastqc_jar} "
            "-i {R1_data_path} "
            "--knownContamFile {snakemake.params.contaminant_file} "
            "--knownAdapterFile {snakemake.params.adapter_file} "
            "--contamsOutputFile {R1_contam_path} "
            "--adapterOutputFile {R1_adapter_path} && echo ok  ) & "
            "( java {snakemake.params.java_extra} "
            "-jar {snakemake.params.extractadaptersfastqc_jar} "
            "-i {R2_data_path} "
            "--knownContamFile {snakemake.params.contaminant_file} "
            "--knownAdapterFile {snakemake.params.adapter_file} "
            "--contamsOutputFile {R2_contam_path} "
            "--adapterOutputFile {R2_adapter_path} && echo ok ) & }}"
            "| grep -c ok | (read n && ((n==2)))")  #check if both succeeded
    else:
        shell("java {snakemake.params.java_extra} "
            "-jar {snakemake.params.extractadaptersfastqc_jar} "
            "-i {R1_data_path} "
            "--knownContamFile {snakemake.params.contaminant_file} "
            "--knownAdapterFile {snakemake.params.adapter_file} "
            "--contamsOutputFile {R1_contam_path} "
            "--adapterOutputFile {R1_adapter_path}")
        shell("java {snakemake.params.java_extra} "
            "-jar {snakemake.params.extractadaptersfastqc_jar} "
            "-i {R2_data_path} "
            "--knownContamFile {snakemake.params.contaminant_file} "
            "--knownAdapterFile {snakemake.params.adapter_file} "
            "--contamsOutputFile {R2_contam_path} "
            "--adapterOutputFile {R2_adapter_path}")
else:
    shell("java {snakemake.params.java_extra} "
        "-jar {snakemake.params.extractadaptersfastqc_jar} "
        "-i {R1_data_path} "
        "--knownContamFile {snakemake.params.contaminant_file} "
        "--knownAdapterFile {snakemake.params.adapter_file} "
        "--contamsOutputFile {R1_contam_path} "
        "--adapterOutputFile {R1_adapter_path}")


# Adapters and contaminants to args
adapters = ""
adapters_file_R1 = open("{}".format(R1_adapter_path), "r")
for x in adapters_file_R1.readlines():
    if x.strip() != "":
        adapters += "-a {} ".format(x.strip())
adapters_file_R1.close()
contaminants_file_R1 = open("{}".format(R1_contam_path), "r")
for x in contaminants_file_R1.readlines():
    if x.strip() != "":
        adapters += "-a {} ".format(x.strip())
contaminants_file_R1.close()
if n == 2:
    adapters_file_R2 = open("{}".format(R2_adapter_path), "r")
    for x in adapters_file_R2.readlines():
        if x.strip()!= "":
            adapters += "-A {} ".format(x.strip())
    adapters_file_R2.close()
    contaminants_file_R2 = open("{}".format(R2_contam_path), "r")
    for x in contaminants_file_R2.readlines():
        if x.strip() != "":
            adapters += "-A {} ".format(x.strip())
    contaminants_file_R2.close()

# determine phred base
with open("{}".format(snakemake.output.encoding), "r") as encoding:
    enc = encoding.read()
    if "Sanger" in enc:
        phred_base = 33
    else:
        phred_base = 64

# Run cutadapt
if n == 2:
    shell("cutadapt {snakemake.params.cutadapt_extra} "
        "--quality-base={phred_base} "
        "-q {snakemake.params.quality_threshold}," #No trailing space!
        "{snakemake.params.quality_threshold} "
        "-m {snakemake.params.minimum_length} "
        "-j {snakemake.threads} "
        "{adapters} "
        "-o {snakemake.output.clean_R1} "
        "-p {snakemake.output.clean_R2} "
        "{snakemake.input} > {snakemake.output.qc_report}")
else:
    shell("cutadapt {snakemake.params.cutadapt_extra} "
        "--quality-base={phred_base} "
        "-q {snakemake.params.quality_threshold}," #No trailing space!
        "{snakemake.params.quality_threshold} "
        "-m {snakemake.params.minimum_length} "
        "-j {snakemake.threads} "
        "{adapters} "
        "-o {snakemake.output.clean_R1} "
        "{snakemake.input} > {snakemake.output.qc_report}")

# Run Fastqc for clean data
output_dir_clean_fastqc_R1 = path.dirname(snakemake.output.clean_html_R1)
if n == 2:
    output_dir_clean_fastqc_R2 = path.dirname(snakemake.output.clean_html_R2)
    clean_output_base_R2 = basename_without_ext(snakemake.output.clean_R2)
    if snakemake.threads > 1:
        shell("{{ ( fastqc --quiet --outdir {output_dir_clean_fastqc_R1} "
            "{snakemake.output.clean_R1} && "
            "echo ok ) & "
            "( fastqc --quiet --outdir {output_dir_clean_fastqc_R2} "
            "{snakemake.output.clean_R2} && "
            "echo ok ) & }} "
            "| grep -c ok | (read n && ((n==2)))") #check if both succeeded
    else:
        shell("fastqc --quiet --outdir {output_dir_clean_fastqc_R1} "
        "{snakemake.output.clean_R1}")
        shell("fastqc --quiet --outdir {output_dir_clean_fastqc_R2} "
        "{snakemake.output.clean_R2}")
    # Get output as made by fastqc
    clean_html_path_R2 = path.join(output_dir_clean_fastqc_R2,
        clean_output_base_R2 + "_fastqc.html")
    clean_zip_path_R2 = path.join(output_dir_clean_fastqc_R2,
        clean_output_base_R2 + "_fastqc.zip")
    # Rename output to match given exptected output names
    if snakemake.output.clean_html_R2 != clean_html_path_R2:
        shell("mv {clean_html_path_R2} {snakemake.output.clean_html_R2}")
    if snakemake.output.clean_zip_R2 != clean_zip_path_R2:
        shell("mv {clean_zip_path_R2} {snakemake.output.clean_zip_R2}")
else:
    shell("fastqc --quiet --outdir {output_dir_clean_fastqc_R1} "
        "{snakemake.output.clean_R1}")
# Get output as made by fastqc
clean_output_base_R1 = basename_without_ext(snakemake.output.clean_R1)
clean_html_path_R1 = path.join(output_dir_clean_fastqc_R1,
    clean_output_base_R1 + "_fastqc.html")
clean_zip_path_R1 = path.join(output_dir_clean_fastqc_R1,
    clean_output_base_R1 + "_fastqc.zip")
# Rename output to match given exptected output names
if snakemake.output.clean_html_R1 != clean_html_path_R1:
    shell("mv {clean_html_path_R1} {snakemake.output.clean_html_R1}")
if snakemake.output.clean_zip_R1 != clean_zip_path_R1:
    shell("mv {clean_zip_path_R1} {snakemake.output.clean_zip_R1}")


# Cleanup
shell("rm {R1_data_path}")
shell("rm {R1_contam_path}")
shell("rm {R1_adapter_path}")
if n == 2:
    shell("rm {R2_data_path}")
    shell("rm {R2_contam_path}")
    shell("rm {R2_adapter_path}")
