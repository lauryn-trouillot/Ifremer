#!/bin/bash 
#PBS -N BAM_to_fastq
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}" 

. /appli/bioinfo/samtools/1.19.2/env.sh

# Déclaration des variables
BAM_FILE="/path/to/bam_file/"
BASENAME=$(basename "$FASTQ_FILE")
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder/BamToFastq_$(date +%Y%m%d_%H%M%S)"
FINAL_OUTPUT="${RESULT_FOLDER}/${BASENAME}.fastq.gz"


# Création des dossiers
mkdir -p "$RESULT_FOLDER"
mkdir -p "$LOG_FOLDER"

# Suppression de l'ancien fichier final s'il existe
if [[ -f "${FINAL_OUTPUT}" ]]; then
    rm -f "${FINAL_OUTPUT}"
fi
        
# Conversion BAM en FASTQ et écriture dans le fichier compressé
samtools fastq "$BAM_FILE" | gzip > "${FINAL_OUTPUT}" 2>> "${LOG_FOLDER}/bam_to_fastq_errors.log"
