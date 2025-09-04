#!/bin/bash
#PBS -N BLAST_count_per_ref
#PBS -q omp
#PBS -l ncpus=8
#PBS -l mem=100gb
#PBS -l walltime=10:00:00

cd "$PBS_O_WORKDIR"
. /appli/bioinfo/blast/2.12.0/env.sh

# Variables
DATE_TAG=$(date +%Y%m%d_%H%M%S)
RESULT_FOLDER="/home1/scratch/ltrouill/blast_count_per_ref_$DATE_TAG"
LOG_FILE="$RESULT_FOLDER/blast_count_per_ref_$DATE_TAG.log"

QUERY="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/trinity/Trinity_20250819_113303.Trinity.fasta"
REF="/home/datawork-lpba/Prymnesium/PrymneGenomeV1/Archive/PrymneTranscriptomeV1_contig_renamed.fasta"

mkdir -p "$RESULT_FOLDER"

echo "$(date) - Début du script blast" > "$LOG_FILE"
echo "Query : $QUERY" >> "$LOG_FILE"
echo "Référence : $REF" >> "$LOG_FILE"

echo "$(date) - Création de la base de données BLAST pour la référence" >> "$LOG_FILE"
makeblastdb -in "$REF" -dbtype nucl -out "$RESULT_FOLDER/ref_db"

echo "$(date) - Alignement BLAST" >> "$LOG_FILE"
blastn -query "$QUERY" -db "$RESULT_FOLDER/ref_db" \
       -out "$RESULT_FOLDER/query_vs_ref.tsv" \
       -outfmt "6 qseqid sseqid pident length qlen slen" \
       -num_threads 8 \
       -evalue 1e-5

echo "$(date) - Comptage par transcrit de référence" >> "$LOG_FILE"
awk '
{
    sseqid=$2
    qseqid=$1
    # éviter de compter deux fois le même query pour un sseqid
    key = sseqid "\t" qseqid
    if (!(key in seen)) {
        seen[key]=1
        count[sseqid]++
    }
}
END {
    print "sseqid\tnb_query_align"
    for (s in count) {
        print s "\t" count[s]
    }
}' "$RESULT_FOLDER/query_vs_ref.tsv" \
| sort -k2,2nr > "$RESULT_FOLDER/count_per_ref.tsv"

total_ref=$(grep -c "^>" "$REF")
with_hits=$(cut -f1 "$RESULT_FOLDER/count_per_ref.tsv" | wc -l)

{
echo "Résumé :"
echo "$with_hits transcrits de référence sur $total_ref ont au moins 1 match"
echo "Fichier de comptage : $RESULT_FOLDER/count_per_ref.tsv"
} >> "$LOG_FILE"

echo "$(date) - Script terminé" >> "$LOG_FILE"
