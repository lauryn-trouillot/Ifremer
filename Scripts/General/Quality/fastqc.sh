#!/bin/bash
#PBS -N fastqc
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
FASTQ_FILE="/path/to/fastq_file"
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder/fastqc_$(date +%Y%m%d_%H%M%S)"

# Création des dossiers
mkdir -p "$LOG_FOLDER" "$OUTPUT_FOLDER"

. /appli/bioinfo/fastqc/0.12.1/env.sh

for FILE in "${FASTQ_FILE[@]}"; do
    fastqc -o "${OUTPUT_FOLDER}" -f fastq "${FILE}" -t 15 --memory 3750 2>> "${LOG_FOLDER}/fastqc_errors.log"
done