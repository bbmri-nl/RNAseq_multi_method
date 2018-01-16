#! /bin/bash
snakemake -p \
	--configfile $@ \
	--snakefile /exports/sasc/dcats/snakemake/RNAseq_multi_method/Snakefile \
	--latency-wait 90 \
	--drmaa " -N preprocessor -pe BWA {threads} -l h_vmem={resources.mem}G -q all.q -cwd -V" \
	--drmaa-log-dir $(pwd)/.cluster_logs \
	--jobs 100 \
	--max-jobs-per-second 10 \
	--restart-times 3 \
	--use-conda \
	--conda-prefix /exports/sasc/dcats/snakemake/.conda
