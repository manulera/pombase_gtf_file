set -e
bash get_data.sh
mkdir -p lib_src

export PATH="$(pwd)/lib/htslib/bin:$PATH"
export PATH="$(pwd)/lib/samtools/bin:$PATH"

GREEN='\033[0;32m'
NC='\033[0m' # No Color

root_dir=$(pwd)

echo -e "${GREEN}Downloading libraries${NC}"

curl -kL https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 -o lib_src/samtools-1.18.tar.bz2
tar -xjf lib_src/samtools-1.18.tar.bz2 -C lib_src/
rm lib_src/samtools-1.18.tar.bz2

curl -kL https://github.com/samtools/htslib/releases/download/1.18/htslib-1.18.tar.bz2 -o lib_src/htslib-1.18.tar.bz2
tar -xjf lib_src/htslib-1.18.tar.bz2 -C lib_src/
rm lib_src/htslib-1.18.tar.bz2

mkdir -p lib
mkdir -p lib/samtools
mkdir -p lib/htslib

echo -e "${GREEN}Installing samtools${NC}"

cd lib_src/samtools-1.18
./configure --prefix="${root_dir}/lib/samtools"
make
make install
rm -rf "${root_dir}/lib/samtools/share"

echo -e "${GREEN}Installing htslib${NC}"

cd ../htslib-1.18
./configure --prefix="${root_dir}/lib/htslib"
make
make install

rm -rf "${root_dir}/lib/htslib/lib"
rm -rf "${root_dir}/lib/htslib/include"
rm -rf "${root_dir}/lib/htslib/share"

cd ${root_dir}

bioconvert gff32gtf --force data/pombe_genome.gff3 data/pombe_genome_unprocessed.gtf
python scripts/pombasegtf_to_ensemblgtf.py --input_file data/pombe_genome_unprocessed.gtf --output_file data/pombe_genome.gtf --gene_types data/gene_IDs_names_products.tsv