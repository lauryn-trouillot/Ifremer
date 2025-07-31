#!/bin/bash 

# Chargement de l'environnement Evigene
. /appli/bioinfo/evigene/20230715/env.sh

NAME=$1
TRANSCRIPTOME_1=$2
TRANSCRIPTOME_2=$3
EVIGINE_FOLDER=$4
RNA_FOLDER=$5

# Définir le fichier log
LOG_FILE="$EVIGINE_FOLDER/evigene.log"

echo "[$(date)] Début de la pipeline - Transcriptome final et séparation ARN"

# Étapes avec logs

echo "[$(date)] Concaténation des transcriptomes..."
cat "$TRANSCRIPTOME_1" "$TRANSCRIPTOME_2" > "$EVIGINE_FOLDER/Conc_${NAME}_transcriptome.fasta"

cd "$EVIGINE_FOLDER"

echo "[$(date)] Lancement de tr2aacds.pl..."
tr2aacds.pl -cdna "Conc_${NAME}_transcriptome.fasta" -logfile "$LOG_FILE" -NCPU 8

echo "[$(date)] Analyse tr2aacds.pl terminée."

# Linéarisation du fichiers fasta (multiligne to 1 ligne)
. /appli/bioinfo/seqkit/2.9.0/env.sh
seqkit seq -w 0 "$EVIGINE_FOLDER/okayset1st/Conc_${NAME}_transcriptome.okay.tr" > "$RNA_FOLDER/All_RNA.fasta"
