
set -e

# Download and extract gff, delete the rest
curl -kL http://sgd-archive.yeastgenome.org/sequence/S288C_reference/genome_releases/S288C_reference_genome_Current_Release.tgz -o data/sgd_genome.tgz
tar -xvzf data/sgd_genome.tgz -C data/
mv data/S288C*/*.gff.gz data/sgd_genome.gff.gz
rm -rf data/S288C*
gzip -fd data/sgd_genome.gff.gz

# Remove the FASTA part
perl -ne 'print; last if /##FASTA/' data/sgd_genome.gff > data/sgd_genome.gff.tmp
mv data/sgd_genome.gff.tmp data/sgd_genome.gff

# Remove problematic ARS lines that are not used
grep -v 'SGD	ARS' data/sgd_genome.gff > data/sgd_genome.gff.tmp
mv data/sgd_genome.gff.tmp data/sgd_genome.gff

# Get the genes that are protein coding in the sgd genome
curl http://sgd-archive.yeastgenome.org/sequence/S288C_reference/orf_protein/orf_trans_all.fasta.gz -o data/current_protein_seqs.fasta.gz
gzip -fd data/current_protein_seqs.fasta.gz
cat data/current_protein_seqs.fasta |grep '>'|cut -d' ' -f1|cut -c 2- > data/protein_coding_sgd.tsv
