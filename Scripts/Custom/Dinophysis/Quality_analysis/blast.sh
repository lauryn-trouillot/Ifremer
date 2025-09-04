#!/bin/bash
#PBS -N BLAST_presence
#PBS -q omp
#PBS -l ncpus=8
#PBS -l mem=100gb
#PBS -l walltime=10:00:00

cd "$PBS_O_WORKDIR"
. /appli/bioinfo/blast/2.12.0/env.sh

# Variables
DATE_TAG=$(date +%Y%m%d_%H%M%S)
RESULT_FOLDER="/home1/scratch/ltrouill/blast_presence_$DATE_TAG"
LOG_FILE="$RESULT_FOLDER/blast_presence_$DATE_TAG.log"
RNABLOOM="/home1/datawork/ltrouill/Ifremer/Results/Dinophysis/rnabloom/rnabloom.transcripts.fasta"
RNASPADES="/home1/datawork/ltrouill/Ifremer/Results/Dinophysis/rnaspades/rnaspades_20250626_090800/transcripts.fasta"
FINAL="/home1/datawork/ltrouill/Ifremer/Results/Dinophysis/Final_transcriptome/Transcriptome_Dinophysis_20250805_142605/FINAL_RNA/All_RNA_95.fasta"

mkdir -p "$RESULT_FOLDER"

echo "$(`date`) - Début du script blast" > "$LOG_FILE"

{
echo "Fichiers :"
echo "rnabloom : $RNABLOOM"
echo "rnaspades : $RNASPADES"
echo "Transcriptome final : $FINAL"
} >> "$LOG_FILE"


echo "$(`date`) - Création de la base de données du transcriptome final" >> "$LOG_FILE"
makeblastdb -in "$FINAL" -dbtype nucl -out "$RESULT_FOLDER/final_db"

echo "$(`date`) - BLAST rnabloom -> final" >> "$LOG_FILE"
blastn -query "$RNABLOOM" -db "$RESULT_FOLDER/final_db" \
       -outfmt "6 qseqid sseqid pident length qlen slen" \
       -num_threads 8 \
       -perc_identity 90 \
       -qcov_hsp_perc 90 \
       > "$RESULT_FOLDER/rnabloom_vs_final.tsv"

echo "$(`date`) - BLAST rnaspades -> final" >> "$LOG_FILE"
blastn -query "$RNASPADES" -db "$RESULT_FOLDER/final_db" \
       -outfmt "6 qseqid sseqid pident length qlen slen" \
       -num_threads 8 \
       -perc_identity 90 \
       -qcov_hsp_perc 90 \
       > "$RESULT_FOLDER/rnaspades_vs_final.tsv"

# Comptage des transcrits présents au moins une fois
total_bloom=$(grep -c "^>" "$RNABLOOM")
total_spades=$(grep -c "^>" "$RNASPADES")
present_bloom=$(cut -f1 "$RESULT_FOLDER/rnabloom_vs_final.tsv" | sort -u | wc -l)
present_spades=$(cut -f1 "$RESULT_FOLDER/rnaspades_vs_final.tsv" | sort -u | wc -l)

{
echo "Résumé :"
echo "rnabloom : $present_bloom sur $total_bloom transcrits présents dans le final"
echo "rnaspades : $present_spades sur $total_spades transcrits présents dans le final"
} >> "$LOG_FILE"
