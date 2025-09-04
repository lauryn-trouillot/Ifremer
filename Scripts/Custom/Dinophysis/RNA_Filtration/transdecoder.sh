#!/bin/bash 

# Script pour exécuter TransDecoder et séparer les ARN codants et non codants
# Il prend en entrée le fichier de consensus, le dossier de sortie pour TransDecoder et le dossier de sortie pour les ARN.

CONSENSUS=$1
TRANSDECODER_FOLDER=$2
RNA_FOLDER=$3
FILENAME=$(basename "$CONSENSUS")

NC_LIST="$TRANSDECODER_FOLDER/ncRNA_name.txt"
mRNA_LIST="$TRANSDECODER_FOLDER/mRNA_name.txt"

echo "[$(date)] Lancement de TransDecoder pour la prédiction des ORFs..."

# Charger l’environnement TransDecoder
. /appli/bioinfo/transdecoder/5.7.1/env.sh

# Exécution de TransDecoder
TransDecoder.LongOrfs -t "$CONSENSUS" -O "$TRANSDECODER_FOLDER"
TransDecoder.Predict -t "$CONSENSUS" -O "$TRANSDECODER_FOLDER"

echo "[$(date)] ORFs prédits par TransDecoder."

# Liste des transcrits codants
ORF_DIR="$TRANSDECODER_FOLDER/${FILENAME}.transdecoder_dir"
grep "^>" "$ORF_DIR/longest_orfs.cds" | cut -d' ' -f1 | sed 's/^>//;s/\.p[0-9]\+$//' | sort -u > "$mRNA_LIST"

# Charger l’environnement SeqKit
. /appli/bioinfo/seqkit/2.9.0/env.sh

echo "[$(date)] Séparation des ARN codants et non codants"

# Filtration des ARNm
seqkit grep -f "$mRNA_LIST" "$CONSENSUS" | seqkit seq -w 0 > "$RNA_FOLDER/mRNA.fasta"

# Filtration des ncRNA (transcrits non codants = tous - codants)
seqkit grep -f "$mRNA_LIST" -v "$CONSENSUS" | seqkit seq -w 0 > "$RNA_FOLDER/ncRNA.fasta"

echo "[$(date)] Fichiers mRNA.fasta et ncRNA.fasta générés dans $RNA_FOLDER"
