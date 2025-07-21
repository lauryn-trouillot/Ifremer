#!/bin/bash 

# Chargement de l'environnement Evigene
. /appli/bioinfo/evigene/20230715/env.sh

NAME=$1
TRANSCRIPTOME_1=$2
EVIGINE_FOLDER=$3
RNA_FOLDER=$4

# Définir le fichier log
LOG_FILE="$EVIGINE_FOLDER/evigene.log"

echo "[$(date)] Début de la pipeline - Transcriptome final et séparation ARN"

# Étapes avec logs

echo "[$(date)] Concaténation des transcriptomes..."
cat "$TRANSCRIPTOME_1" > "$EVIGINE_FOLDER/Conc_${NAME}_transcriptome.fasta"

cd "$EVIGINE_FOLDER"

echo "[$(date)] Lancement de tr2aacds.pl..."
tr2aacds.pl -cdna "Conc_${NAME}_transcriptome.fasta" -logfile "$LOG_FILE" -NCPU 8

echo "[$(date)] Analyse tr2aacds.pl terminée."

# Séparation des ARN en fichiers 
NC_LIST="$EVIGINE_FOLDER/ncRNA_name.txt"
mRNA_LIST="$EVIGINE_FOLDER/mRNA_name.txt"

echo "[$(date)] Récupération du nom des transcrits codant et non codant"

#Récupération des noms des ARNm et des ARN non codants 
grep -E 'evgclass=noclass|evgclass=noclassnc' "$EVIGINE_FOLDER/okayset1st/Conc_${NAME}_transcriptome.okay.tr" | tr -d ">" > $NC_LIST
grep '^>' "$EVIGINE_FOLDER/okayset1st/Conc_${NAME}_transcriptome.okay.tr" | grep -v -E 'evgclass=noclass|evgclass=noclassnc' | tr -d ">" > $mRNA_LIST

# Linéarisation du fichiers fasta (multiligne to 1 ligne)
. /appli/bioinfo/seqkit/2.9.0/env.sh
seqkit seq -w 0 "$EVIGINE_FOLDER/okayset1st/Conc_${NAME}_transcriptome.okay.tr" > "$RNA_FOLDER/All_RNA.fasta"

echo "[$(date)] Séparation du transcriptome en 2 fichier : ARN non codant et potentiel ARNm" >> "$LOG_FILE"

# Filtration des transcripts non codants 
seqkit grep -n -f "$NC_LIST" "$RNA_FOLDER/All_RNA.fasta" | seqkit seq -w 0 > "$RNA_FOLDER/ncRNA.fasta"

# Filtration des ARNm 
seqkit grep -n -f "$mRNA_LIST" "$RNA_FOLDER/All_RNA.fasta" | seqkit seq -w 0 > "$RNA_FOLDER/mRNA.fasta"
