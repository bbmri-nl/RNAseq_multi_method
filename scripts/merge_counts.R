#time Rscript ./merge.R .non_stranded.gene.counts gene Hof* | gzip -c > gene.counts.tsv.gz
# time Rscript ./merge.R .non_stranded.exon.counts exon Hof* | gzip -c > exon.counts.tsv.gz

# Author: Ioannis Moustakas, i.moustakas@lumc.nl (Based on a script by Szymon Kielbasa)
# Modified for snakemake by Davy Cats, d.cats@lumc.nl
# Title: Merge count files from featureCouns output
# Use: Rscript merge.R columnIDToMergeOn columnIDBeingMerged ListOfFilesToBeMerged > mergedOutput

### Load Packages
library( dplyr )
library( reshape2 )

print(snakemake)

### load arguments from the command line
#args <- commandArgs( trailingOnly = TRUE )
idVars <- snakemake@params$idVars
measureVars <- snakemake@params$measureVars
listOfFiles <- snakemake@input

### Iterate over the list of files that are being merged. Change the column name (sample name) to a sorter one
d <- do.call( rbind, lapply( listOfFiles, function( file ) {
 d <- read.table( file, header = TRUE , comment.char = "#")
 #fileName <- colnames(d)[measureVars]
 #substrings <- unlist(strsplit(fileName, "\\."))
 colnames(d)[measureVars] <- strsplit(file, "/")[[1]][3] 
 d <- d %>% melt( id.vars = idVars, measure.vars=measureVars, variable.name = "sample", value.name = "count" )

} ) )

### Reformat the data frame and output (in STDOUT) the merged table.
d <- d %>% dcast( paste0( idVars, " ~ sample" ), value.var = "count" )
write.table( d, file=snakemake@output[[1]], sep = "\t", quote = FALSE, row.names = FALSE )
