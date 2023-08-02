# PomBase GTF file

A script to convert pombase gff3 file into GFT format compatible with transvar.

## Requirements for running using docker

You need to have docker installed. Then simply run: `bash run_with_docker.sh`

The output gtf file will be at `data/pombase_genome.gtf`.

What it does:

* Downloads some files from pombase (see `get_data.sh`).
* Uses bioconvert to convert from gff3 to GFT.
* Further processes the GFT file to be compatible with transvar. The code uses the python installation of the container to run the script `scripts/pombasegtf_to_ensemblgtf.py`.

## Requirements for running locally

Install python dependencies and activate virtual env:

```bash
poetry install
poetry shell
```

See the file `run_locally.sh`, which downloads and installs several dependencies:

* `samtools`
* `htslib`

Then runs bioconvert as well as the python script.
