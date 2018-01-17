# RNAseq multi method

## Requirements
- A (mini-)conda installation
- A snakemake installation
- pandas (python3 library)
- cerberus (python3 library)
- biopet tools:
  - bamstats
  - basecounter

## Included Mappers
- STAR
- STAR 2-pass
- HISAT2 (doesn't work)

## Included Counting methods
- HTSeq-count
- featureCounts
- STAR QuantMode
- basecounter
  - exon
  - intron
  - transcript
  - gene

## Author
Davy Cats (D.Cats@lumc.nl)
