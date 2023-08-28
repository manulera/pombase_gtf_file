set -e
bash get_data_sgd.sh

bioconvert gff32gtf --force data/sgd_genome.gff data/sgd_genome_unprocessed.gtf
python scripts/sgdgtf_to_ensemblgtf.py --input_file data/sgd_genome_unprocessed.gtf --output_file data/sgd_genome.gtf