#!/bin/bash

# Ce script exécute tRNAscan-SE pour identifier les tRNA dans un fichier FASTA
# et sépare les tRNA des autres ARN non codants.
# Il prend en entrée un fichier FASTA contenant des ARN, un dossier de sortie pour tRNAscan et un dossier de sortie pour les ARN.

. /appli/bioinfo/trnascan-se/2.0.7/env.sh

# Récupération des variables
NON_RRNA=$1
TRNASCAN_FOLDER=$2
RNA_FOLDER=$3

# Chemins
LOG_FILE="$TRNASCAN_FOLDER/trnascan.log"
TRNA_LIST="$TRNASCAN_FOLDER/trna_name.txt"

tRNAscan-SE -G \
  -m "$TRNASCAN_FOLDER/statistics_summary.txt" \
  -l "$LOG_FILE" \
  -o "$TRNASCAN_FOLDER/trnascan_results.txt" \
  "$NON_RRNA"


sed 1,3d "$TRNASCAN_FOLDER/trnascan_results.txt" \
  | cut -f1 \
  | sort \
  | uniq \
  | tr -d '\r' \
  | sed 's/[[:space:]]*$//' > "$TRNA_LIST"


. /appli/bioinfo/seqkit/2.9.0/env.sh

# Filtration des ARNr parmi les non codants
seqkit grep -f "$TRNA_LIST" -i "$NON_RRNA" | seqkit seq -w 0 > "$RNA_FOLDER/tRNA.fasta"
seqkit grep -f "$TRNA_LIST" -v -i "$NON_RRNA" | seqkit seq -w 0 > "$RNA_FOLDER/others_ncRNA.fasta"
