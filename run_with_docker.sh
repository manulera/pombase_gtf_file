set -e
bash get_data.sh

# Get docker image
docker pull quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0

# Run file conversion using docker
docker run --rm -v $PWD/scripts:/scripts:ro -v $PWD/data:/data quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0\
        bioconvert gff32gtf --force data/pombe_genome.gff3 data/pombe_genome_unprocessed.gtf;
        python scripts/pombasegtf_to_ensemblgtf.py --input_file data/pombe_genome_unprocessed.gtf --output_file data/pombe_genome.gtf --gene_types data/gene_IDs_names_products.tsv
