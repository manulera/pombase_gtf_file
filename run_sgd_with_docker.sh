set -e
# bash get_data_sgd.sh

# Get docker image
docker pull quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0

# Run file conversion using docker
docker run --rm -v $PWD/scripts:/scripts:ro -v $PWD/data:/data quay.io/biocontainers/bioconvert:1.1.1--pyhdfd78af_0 /bin/bash -c \
        "bioconvert gff32gtf --force data/sgd_genome.gff data/sgd_genome_unprocessed.gtf;\
        python scripts/sgdgtf_to_ensemblgtf.py --input_file data/sgd_genome_unprocessed.gtf --output_file data/sgd_genome.gtf --protein_coding_file data/protein_coding_sgd.tsv"
