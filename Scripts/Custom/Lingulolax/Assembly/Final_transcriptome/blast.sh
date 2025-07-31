#!/bin/bash

# Ce script effectue une recherche BLAST des ARNr dans un fichier fasta
# Il prend en entrée le nom du transcriptome, le fichier fasta (représentant les non codants ici), le dossier de résultats et le dossier des fichiers RNA finaux
# Il génère des fichiers de sortie pour les ARNr
# et un résumé des résultats

. /appli/bioinfo/blast/2.12.0/env.sh

# Chemins en dur
NAME=$1
NC_RNA=$2
BLAST_FOLDER=$3
RNA_FOLDER=$4

DB_18S="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blastdb/18S_fungal_sequences/18S_fungal_sequences"
DB_28S="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blastdb/28S_fungal_sequences/28S_fungal_sequences"
DB_58S="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blastdb/5_8S_sequences/5_8_rRNA_db"

OUT_18S="$BLAST_FOLDER/${NAME}_vs_18S.txt"
OUT_28S="$BLAST_FOLDER/${NAME}_vs_28S.txt"
OUT_58S="$BLAST_FOLDER/${NAME}_vs_58S.txt"
CANDIDATES_18S="$BLAST_FOLDER/${NAME}_18S_candidates.txt"
CANDIDATES_28S="$BLAST_FOLDER/${NAME}_28S_candidates.txt"
CANDIDATES_58S="$BLAST_FOLDER/${NAME}_58S_candidates.txt"
ALL_RRNA="$BLAST_FOLDER/${NAME}_rRNA_candidates.txt"
SUMMARY="$BLAST_FOLDER/${NAME}_rRNA_summary.txt"
LOG_FILE="$BLAST_FOLDER/blast.log"

### Recherche des ARNr 18S
## On prend une petite e-value pour les espèces relativement proches
echo "[`date`] BLASTN vs 18S..." >> $LOG_FILE
blastn -query "$NC_RNA" -db "$DB_18S" \
  -out "$OUT_18S" \
  -evalue 1e-20 \
  -outfmt 6  \
  -num_threads 4 2>> "$LOG_FILE"

echo "[`date`] Extraction des identifiants 18S..." >> $LOG_FILE

cut -f1 "$OUT_18S" | sort | uniq > "$CANDIDATES_18S"

### Recherche des ARNr 28S
echo "[`date`] BLASTN vs 28S..." >> $LOG_FILE
blastn -query "$NC_RNA" -db "$DB_28S" \
  -out "$OUT_28S" \
  -evalue 1e-20 \
  -outfmt 6 \
  -num_threads 4 2>> "$LOG_FILE"

echo "[`date`] Extraction des identifiants 28S..." >> $LOG_FILE

cut -f1 "$OUT_28S" | sort | uniq > "$CANDIDATES_28S"

### Recherche des ARNr 5.8S
echo "[`date`] BLASTN vs 5.8S..." >> $LOG_FILE
blastn -query "$NC_RNA" -db "$DB_58S" \
  -out "$OUT_58S" \
  -evalue 1e-20 \
  -outfmt 6 \
  -num_threads 4 2>> "$LOG_FILE"

echo "[`date`] Extraction des identifiants 5.8S..." >> $LOG_FILE

cut -f1 "$OUT_58S" | sort | uniq > "$CANDIDATES_58S"

echo "[`date`] Fusion des candidats ARNr..." >> $LOG_FILE

cat "$CANDIDATES_18S" "$CANDIDATES_28S" "$CANDIDATES_58S" | sort | uniq > "$ALL_RRNA"

# Résumé
TOTAL=$(grep -c "^>" "$NC_RNA")
N_18S=$(wc -l < "$CANDIDATES_18S")
N_28S=$(wc -l < "$CANDIDATES_28S")
N_58S=$(wc -l < "$CANDIDATES_58S")
N_TOTAL=$(wc -l < "$ALL_RRNA")

P_18S=$(awk -v n=$N_18S -v t=$TOTAL 'BEGIN {printf "%.2f", (n/t)*100}')
P_28S=$(awk -v n=$N_28S -v t=$TOTAL 'BEGIN {printf "%.2f", (n/t)*100}')
P_58S=$(awk -v n=$N_58S -v t=$TOTAL 'BEGIN {printf "%.2f", (n/t)*100}')
P_TOTAL=$(awk -v n=$N_TOTAL -v t=$TOTAL 'BEGIN {printf "%.2f", (n/t)*100}')

echo "[`date`] Résumé écrit dans $SUMMARY"
cat <<EOF > "$SUMMARY"
Transcriptome analysé : $NC_RNA
Nombre total de transcripts : $TOTAL

> ARNr 18S : $N_18S transcripts (${P_18S}%)
> ARNr 28S : $N_28S transcripts (${P_28S}%)
> ARNr 5.8S : $N_58S transcripts (${P_58S}%)
> Total ARNr uniques (18S + 28S + 5.8S) : $N_TOTAL transcripts (${P_TOTAL}%)
EOF

cat "$SUMMARY"
echo "[`date`] Analyse terminée." >> $LOG_FILE

. /appli/bioinfo/seqkit/2.9.0/env.sh

# Filtration des ARNr parmi les non codants
seqkit grep -f "$ALL_RRNA" "$NC_RNA" | seqkit seq -w 0 > "$RNA_FOLDER/rRNA.fasta"

seqkit grep -f "$ALL_RRNA" -v "$NC_RNA" | seqkit seq -w 0 > "$RNA_FOLDER/nonrRNA.fasta"
