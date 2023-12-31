"""
This script converts the gtf file from PomBase to the format of Ensembl gtf files.
It adds gene_biotype and transcript_biotype attributes based on the data from the file
gene_IDs_names_products.tsv from releases
"""
import pandas
import csv
import argparse


# At least in the old ensembl assembly, there are no pseudogenes with CDS
biotype_mappings = {
    'lncRNA gene': 'ncRNA',
    'ncRNA gene': 'ncRNA',
    'protein coding gene': 'protein_coding',
    'pseudogene': 'pseudogene',
    'rRNA gene': 'rRNA',
    'snRNA gene': 'snRNA',
    'sncRNA gene': 'ncRNA',
    'snoRNA gene': 'snoRNA',
    'tRNA gene': 'tRNA',
}

def main(input_file, output_file, gene_types_file):

    gene_info = pandas.read_csv(gene_types_file, sep='\t')
    protein_coding_genes = set(gene_info.loc[gene_info.gene_type == 'protein coding gene', 'gene_systematic_id'])
    systematic_id_to_gene_type = dict(zip(gene_info.gene_systematic_id, gene_info.gene_type))

    data = pandas.read_csv(input_file, sep='\t', header=None)
    data.columns = ['seqname', 'source', 'feature', 'start', 'end', 'score', 'strand', 'frame', 'attribute']

    data['systematic_id'] = data.attribute.str.extract('gene_id "([^"]+)"')

    # In the gtf file generated by bioconvert, the RNA genes exons are saved as CDS (WARNING: maybe the library changes in the future)
    data.loc[(data.feature == 'CDS') & ~data.systematic_id.isin(protein_coding_genes), 'feature'] = 'exon'

    row_list = list()
    for i, row in data.iterrows():

        # Add gene row on top of transcript
        if row.feature == 'transcript':
            gene_biotype = biotype_mappings[systematic_id_to_gene_type[row.systematic_id]]
            gene_row = row.copy()
            gene_row.feature = 'gene'
            gene_row.attribute = 'gene_id "{}"; gene_biotype "{}";'.format(row.systematic_id, gene_biotype)
            row_list.append(gene_row)

            # Add gene_biotype to transcript (for some reason the transcript rows generated by bioconvert don't end on ";") (WARNING: maybe the library changes in the future)
            row.attribute = row.attribute + '; transcript_biotype "{}";'.format(gene_biotype)
            row_list.append(row)
        else:
            row_list.append(row)

    out_data = pandas.DataFrame(row_list)

    # We want to have a single row for each gene, so we transform it into the one that encompasses all the transcripts
    repeated_genes = out_data.loc[out_data.feature == 'gene', :]
    repeated_genes = repeated_genes[repeated_genes['systematic_id'].duplicated(keep=False)]
    repeated_genes = repeated_genes.groupby(['systematic_id', 'feature'], as_index=False).agg({'start': lambda x: min(x), 'end': lambda x: max(x)})
    repeated_genes.rename(columns={'start': 'new_start', 'end': 'new_end'}, inplace=True)
    out_data = out_data.merge(repeated_genes, on=['systematic_id', 'feature'], how='left')
    # Substitute the start and end of the gene by the new ones where they exist
    out_data.loc[~out_data.new_start.isna(), 'start'] = out_data.loc[~out_data.new_start.isna(), 'new_start']
    out_data.loc[~out_data.new_end.isna(), 'end'] = out_data.loc[~out_data.new_end.isna(), 'new_end']
    out_data.drop(columns=['systematic_id', 'new_start', 'new_end'], inplace=True)
    out_data.drop_duplicates(inplace=True)
    out_data.to_csv(output_file, sep='\t', quoting=csv.QUOTE_NONE, header=False, index=False)


if __name__ == '__main__':
    class Formatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=Formatter)
    parser.add_argument('--input_file', help='input gtf file')
    parser.add_argument('--output_file', help='corrected gtf file')
    parser.add_argument('--gene_types', help='file that contains gene types (gene_IDs_names_products.tsv from release)')
    args = parser.parse_args()
    main(args.input_file, args.output_file, args.gene_types)