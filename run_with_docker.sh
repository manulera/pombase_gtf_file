set -e
bash get_data.sh

# Get docker image
docker pull quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0
docker run -d quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0

# Run file conversion using docker
docker run --rm -v $PWD/data:/data -v $PWD/data:/data \
        bioconvert gff32gtf --force data/pombe_genome.gff3 data/pombe_genome_unprocessed.gtf;
        python temp_scripts/pombasegtf_to_ensemblgtf.py --input_file ../data/pombe_genome_unprocessed.gtf --output_file ../data/pombe_genome.gtf --gene_types ../data/gene_IDs_names_products.tsv


# Run the script pombasegtf_to_ensemblgtf inside the container, which comes with pandas installed
docker run --rm -v $PWD/scripts:/temp_scripts:ro -v $PWD/data:/data quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0 python temp_scripts/pombasegtf_to_ensemblgtf.py --input_file ../data/pombe_genome_unprocessed.gtf --output_file ../data/pombe_genome.gtf --gene_types ../data/gene_IDs_names_products.tsv
