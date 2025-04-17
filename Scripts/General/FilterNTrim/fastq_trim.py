import gzip
from Bio import SeqIO
import argparse

def mean_quality(qualities):
    return sum(qualities) / len(qualities) if qualities else 0

def is_mrna(seq, quality_scores, min_quality=10, polyA_threshold=10):
    """Détermine si la séquence est un ARNm basé sur la queue poly(A) ou poly(T) et la qualité."""
    polyA_tail = seq[-polyA_threshold:].count("A") >= (polyA_threshold * 0.8)
    polyT_tail = seq[:polyA_threshold].count("T") >= (polyA_threshold * 0.8)
    return (polyA_tail or polyT_tail) and mean_quality(quality_scores) >= min_quality

def is_dna(seq, length_threshold=1000):
    """Détermine si la séquence est probablement de l'ADN en fonction de sa longueur."""
    return len(seq) >= length_threshold

def calculate_n50(lengths):
    """Calcule la N50 d'une liste de longueurs de séquences."""
    if not lengths:
        return 0
    lengths.sort(reverse=True)
    total_length = sum(lengths)
    cum_length = 0
    for length in lengths:
        cum_length += length
        if cum_length >= total_length / 2:
            return length
    return 0

def generate_report(stats, output_report):
    """Génère un rapport avec le nombre de séquences, la taille min/max et la N50."""
    with open(output_report, "w") as report:
        for category, lengths in stats.items():
            if lengths:
                report.write(f"{category} :\n")
                report.write(f"  Nombre de séquences : {len(lengths)}\n")
                report.write(f"  Taille minimale : {min(lengths)}\n")
                report.write(f"  Taille maximale : {max(lengths)}\n")
                report.write(f"  N50 : {calculate_n50(lengths)}\n\n")
            else:
                report.write(f"{category} : Aucune séquence\n\n")

def sort_fastq(input_fastq, output_mrna, output_dna, output_other, output_rna, output_report, min_quality=10, polyA_threshold=10, length_threshold=1000):
    open_func = gzip.open if input_fastq.endswith(".gz") else open
    stats = {"ARNm": [], "ADN": [], "Autres": [], "ARN": []}
    
    with open_func(input_fastq, "rt") as infile, \
         open(output_mrna, "w") as mrna_out, \
         open(output_dna, "w") as dna_out, \
         open(output_other, "w") as other_out, \
         open(output_rna, "w") as rna_out : 

        for record in SeqIO.parse(infile, "fastq"):
            seq = str(record.seq)
            quality_scores = record.letter_annotations["phred_quality"]
            seq_length = len(seq)

            if is_mrna(seq, quality_scores, min_quality, polyA_threshold):
                SeqIO.write(record, mrna_out, "fastq")
                SeqIO.write(record, rna_out, "fastq")
                stats["ARNm"].append(seq_length)
            elif is_dna(seq, length_threshold):
                SeqIO.write(record, dna_out, "fastq")
                stats["ADN"].append(seq_length)
            else:
                SeqIO.write(record, other_out, "fastq")
                stats["Autres"].append(seq_length)
                SeqIO.write(record, rna_out, "fastq")
    
    generate_report(stats, output_report)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Trie les séquences FASTQ en ARNm, ADN et autres et génère un rapport.")
    parser.add_argument("input_fastq", help="Fichier FASTQ d'entrée")
    parser.add_argument("output_mrna", help="Fichier FASTQ des ARNm")
    parser.add_argument("output_dna", help="Fichier FASTQ des ADN")
    parser.add_argument("output_other", help="Fichier FASTQ des séquences non classées")
    parser.add_argument("output_rna", help="Fichier FASTQ des ARN")
    parser.add_argument("output_report", help="Fichier de rapport")
    parser.add_argument("--min_quality", type=int, default=10, help="Score de qualité minimum (default: 10)")
    parser.add_argument("--polyA_threshold", type=int, default=10, help="Longueur minimale de la queue poly(A) (default: 10)")
    parser.add_argument("--length_threshold", type=int, default=10000, help="Seuil de longueur pour classer comme ADN (default: 10000 nt)")
    
    args = parser.parse_args()
    sort_fastq(args.input_fastq, args.output_mrna, args.output_dna, args.output_other, args.output_rna, args.output_report, args.min_quality, args.polyA_threshold, args.length_threshold)
