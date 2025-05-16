from Bio import SeqIO
from collections import defaultdict
import sys

def get_longest_isoforms_by_gene(fasta_path, output_path, report_path):
    isoforms_by_gene = defaultdict(list)

    # Regrouper les isoformes par gène
    with open(fasta_path) as handle:
        for record in SeqIO.parse(handle, "fasta"):
            header = record.id
            sequence = str(record.seq)
            # Extraire ID de gène (ex : g0 de NODE_1_length_..._g0_i0)
            gene_match = header.split('_')
            gene_id = [chunk for chunk in gene_match if chunk.startswith('g') and not chunk.startswith('gene')][0]
            isoforms_by_gene[gene_id].append((record, len(sequence)))

    # Choisir le plus long pour chaque gène
    selected_records = []
    with open(report_path, 'w') as report:
        report.write("Compte rendu : sélection des isoformes les plus longs\n")
        report.write("=====================================================\n\n")
        report.write(f"Nombre total de gènes : {len(isoforms_by_gene)}\n\n")

        for gene_id, records in isoforms_by_gene.items():
            records_sorted = sorted(records, key=lambda x: x[1], reverse=True)
            longest_record, longest_len = records_sorted[0]
            selected_records.append(longest_record)

            report.write(f"Gène : {gene_id}\n")
            report.write(f"  → Isoforme retenu : {longest_record.id} ({longest_len} nt)\n")
            if len(records_sorted) > 1:
                report.write("  ✗ Isoformes supprimés :\n")
                for rec, l in records_sorted[1:]:
                    report.write(f"     - {rec.id} ({l} nt)\n")
            else:
                report.write("  ✓ Un seul isoforme disponible\n")
            report.write("\n")

    # Sauvegarde des séquences retenues au format fasta-2line
    with open(output_path, "w") as out_handle:
        SeqIO.write(selected_records, out_handle, "fasta-2line")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python extract_longest_isoforms.py <input_fasta> <output_fasta> <report_txt>")
        sys.exit(1)

    input_fasta = sys.argv[1]
    output_fasta = sys.argv[2]
    report_txt = sys.argv[3]
    get_longest_isoforms_by_gene(input_fasta, output_fasta, report_txt)
