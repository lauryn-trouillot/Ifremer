#!/bin/bash 
#PBS -N Final_transcriptome
#PBS -q omp
#PBS -l ncpus=8
#PBS -l mem=100gb
#PBS -l walltime=10:00:00

# Ce script est utilisé pour former le transcriptome consensus a partir de plusieurs transcriptomes (Ici 2)
# Il prend en entrée le nom du transcriptome, les fichiers fasta des transcriptomes à assembler, le dossier de résultats et le dossier des fichiers RNA finaux

cd "$PBS_O_WORKDIR"

# Chargement de l'environnement Evigene
. /appli/bioinfo/evigene/20230715/env.sh

# Définir les fichiers d'entrée
TRANSCRIPTOME_1="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/rnaspades/rnaspades_20250418_145703/transcripts.fasta"
TRANSCRIPTOME_2="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/rnabloom/rnabloom_20250717_180152/rnabloom.transcripts.fasta"
NAME=Prymnesium
EVIGINE_FOLDER="/home1/scratch/ltrouill/Transcriptome_${NAME}_$(date +%Y%m%d_%H%M%S)"


# Définir le fichier log
LOG_FILE="$EVIGINE_FOLDER/evigene.log"


echo "[$(date)] Concaténation des transcriptomes..."
cat "$TRANSCRIPTOME_1" "$TRANSCRIPTOME_2" > "$EVIGINE_FOLDER/Conc_${NAME}_transcriptome.fasta"

cd "$EVIGINE_FOLDER"

echo "[$(date)] Lancement de tr2aacds.pl..."
tr2aacds.pl -cdna "Conc_${NAME}_transcriptome.fasta" -logfile "$LOG_FILE" -NCPU 8

echo "[$(date)] Analyse tr2aacds.pl terminée."

awk '$2 == "okay"  {print $1}' "Conc_${NAME}_transcriptome.trclass" | sed 's/utrorf$//' > "All_RNA.txt"

# Linéarisation du fichiers fasta (multiligne to 1 ligne)
. /appli/bioinfo/seqkit/2.9.0/env.sh
seqkit grep -f "All_RNA.txt" "Conc_${NAME}_transcriptome.fasta" | seqkit seq -w 0 > "$EVIGINE_FOLDER/All_RNA.fasta"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CLUSTER_NAME="cluster_${TIMESTAMP}"
CLUSTER_FOLDER="${EVIGINE_FOLDER}/${CLUSTER_NAME}"
CLUSTER_LOG="${CLUSTER_FOLDER}/${CLUSTER_NAME}.log"
CLUSTER_FILE="${EVIGINE_FOLDER}/All_RNA_95.fasta"

mkdir -p "$CLUSTER_FOLDER"

THRESHOLD_VALUE=9
SIMILARITY_VALUE=0.95

. /appli/bioinfo/cd-hit/4.8.1/env.sh

echo "[$(date)] Clusterisation du transcriptome au seuil ${SIMILARITY_VALUE}..."

cd-hit-est -i "${EVIGINE_FOLDER}/All_RNA.fasta" \
           -o "${CLUSTER_FILE}" \
           -c "${SIMILARITY_VALUE}" \
           -n "${THRESHOLD_VALUE}" \
           -M 100000 \
           -T 15 >> "${CLUSTER_LOG}" 2>&1

echo "[$(date)] Clusterisation terminée."


