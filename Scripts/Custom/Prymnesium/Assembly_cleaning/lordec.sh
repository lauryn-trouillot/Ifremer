#!/bin/bash
#PBS -N lordec-correct
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"


# Définition de la date/heure actuelle pour nommer les fichiers/dossiers
DATE_TAG=$(date +"%Y%m%d_%H%M%S")

# Fichiers et dossiers
LR_FILE="/home/datawork-lpba/Prymnesium/PrymneTranscripto/AssemblageGreg/ClusterRattelCustomGreg-Primnesium.fasta"
SR_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Prymnesium/Short_reads/fastp_20250407_081434"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/lordec"
RESULT_FOLDER="/home1/scratch/ltrouill/lordec_${DATE_TAG}"
LOG_FILE="${LOG_FOLDER}/lordec_${DATE_TAG}.log"


# Création des dossiers
mkdir -p "$RESULT_FOLDER" "$LOG_FOLDER"

echo "[$(date)] Début de la pipeline LoRDEC" > "$LOG_FILE"

# Décompression des fichiers short reads
echo "[$(date)] Décompression des fichiers short reads..." >> "$LOG_FILE"
gunzip -c "$SR_FOLDER/AA_R1.cleaned.fastq.gz" > "$RESULT_FOLDER/AA_R1.cleaned.fastq"
gunzip -c "$SR_FOLDER/AA_R2.cleaned.fastq.gz" > "$RESULT_FOLDER/AA_R2.cleaned.fastq"
echo "[$(date)] Décompression terminée." >> "$LOG_FILE"

# Correction des long reads
echo "[$(date)] Lancement de la correction avec LoRDEC..." >> "$LOG_FILE"
/home1/datawork/ltrouill/lordec-bin_0.8_linux64/lordec-bin_0.8/lordec-correct \
  -2 "$RESULT_FOLDER/AA_R1.cleaned.fastq","$RESULT_FOLDER/AA_R2.cleaned.fastq" \
  -k 19 \
  -s 3 \
  -i "$LR_FILE" \
  -o "$RESULT_FOLDER/corrected_assembly.fasta" \
  --threads 15 \
  2>> "$LOG_FILE"

echo "[$(date)] Pipeline terminée." >> "$LOG_FILE"
