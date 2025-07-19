#!/bin/bash
#PBS -N blast_rrna
#PBS -l ncpus=4
#PBS -l mem=16gb
#PBS -l walltime=01:00:00
#PBS -q omp


cd $PBS_O_WORKDIR

. /appli/bioinfo/blast/2.12.0/env.sh

# Chemins en dur
TRANSCRIPTS="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/rnabloom/rnabloom_20250425_085518/rnabloom.transcripts.fasta"
PREFIX="rnabloom"

DB_18S="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blastdb/18S_fungal_sequences/18S_fungal_sequences"
DB_28S="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blastdb/28S_fungal_sequences/28S_fungal_sequences"
DB_58S="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blastdb/5_8S_sequences/5_8_rRNA_db"

RESULTS_FOLDER="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/blast/blast_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$RESULTS_FOLDER"

OUT_18S="$RESULTS_FOLDER/${PREFIX}_vs_18S.txt"
OUT_28S="$RESULTS_FOLDER/${PREFIX}_vs_28S.txt"
OUT_58S="$RESULTS_FOLDER/${PREFIX}_vs_58S.txt"
CANDIDATES_18S="$RESULTS_FOLDER/${PREFIX}_18S_candidates.txt"
CANDIDATES_28S="$RESULTS_FOLDER/${PREFIX}_28S_candidates.txt"
CANDIDATES_58S="$RESULTS_FOLDER/${PREFIX}_58S_candidates.txt"
ALL_RRNA="$RESULTS_FOLDER/${PREFIX}_rRNA_candidates.txt"
SUMMARY="$RESULTS_FOLDER/${PREFIX}_rRNA_summary.txt"
LOG_FILE="$RESULTS_FOLDER/blast_$(date +%Y%m%d_%H%M%S).log"

### Recherche des ARNr 18S 
echo "[`$(date)`] BLASTN vs 18S..." > $LOG_FILE
blastn -query "$TRANSCRIPTS" -db "$DB_18S" -out "$OUT_18S" -evalue 1e-20 -outfmt 6 -num_threads 4 2>> "$LOG_FILE"

echo "[`date`] Extraction des identifiants 18S..." >> $LOG_FILE

cut -f1 "$OUT_18S" | sort | uniq > "$CANDIDATES_18S"

### Recherche des ARNr 28S
echo "[`date`] BLASTN vs 28S..." >> $LOG_FILE
blastn -query "$TRANSCRIPTS" -db "$DB_28S" -out "$OUT_28S" -evalue 1e-20 -outfmt 6 -num_threads 4 2>> "$LOG_FILE"

echo "[`date`] Extraction des identifiants 28S...">> $LOG_FILE

cut -f1 "$OUT_28S" | sort | uniq > "$CANDIDATES_28S"

### Recherche des ARNr 5.8S
echo "[`date`] BLASTN vs 5.8S..." >> $LOG_FILE
blastn -query "$TRANSCRIPTS" -db "$DB_58S" -out "$OUT_58S" -evalue 1e-20 -outfmt 6 -num_threads 4 2>> "$LOG_FILE"

echo "[`date`] Extraction des identifiants 5.8S...">> $LOG_FILE

cut -f1 "$OUT_58S" | sort | uniq > "$CANDIDATES_58S"


echo "[`date`] Fusion des candidats ARNr...">> $LOG_FILE

cat "$CANDIDATES_18S" "$CANDIDATES_28S" "$CANDIDATES_58S" | sort | uniq > "$ALL_RRNA"

# Résumé
TOTAL=$(grep -c "^>" "$TRANSCRIPTS")
# TOTAL=$(($(wc -l < "$TRANSCRIPTS") / 4)) Pour les reads brute fastq
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
Transcriptome analysé : $TRANSCRIPTS
Nombre total de transcripts : $TOTAL

> ARNr 18S : $N_18S transcripts (${P_18S}%)
> ARNr 28S : $N_28S transcripts (${P_28S}%)
> ARNr 5.8S : $N_58S transcripts (${P_58S}%)
> Total ARNr uniques (18S + 28S + 5.8S) : $N_TOTAL transcripts (${P_TOTAL}%)
EOF

cat "$SUMMARY"
echo "[`date`] Analyse terminée.">> $LOG_FILE

