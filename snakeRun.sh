snakemake -p \
	--config $@ \
	--cluster-config /exports/sasc/dcats/snakemake/RNAseq_multi_method/cluster_config.yml \
	--latency-wait 90 \
	--drmaa " -N preprocessor -pe BWA {threads} -l h_vmem={cluster.mem} -q all.q -cwd -V" \
	--drmaa-log-dir /exports/sasc/dcats/snakemake/testOut/cluster_logs \
	--jobs 100 \
	--max-jobs-per-second 10 \
	--use-conda \
	--conda-prefix /exports/sasc/dcats/snakemake/.conda
