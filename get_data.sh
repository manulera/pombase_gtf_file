set -e
mkdir -p data

# This file is used to tell the type of genes (protein coding, etc.)
curl -k https://www.pombase.org/data/names_and_identifiers/gene_IDs_names_products.tsv -o data/gene_IDs_names_products.tsv

# We download the pombase gff3
curl -k https://curation.pombase.org/dumps/latest_build/gff/Schizosaccharomyces_pombe_all_chromosomes.gff3 -o data/pombe_genome.gff3
