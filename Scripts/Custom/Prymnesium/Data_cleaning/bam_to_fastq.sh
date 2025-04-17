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
RESULT_FOLDER="/home1/datawork/ltrouill/ifremer/data/rawdata/minion"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors"
FINAL_OUTPUT="${RESULT_FOLDER}/Prymnesium_cDNA.fastq.gz"

BAM_FILE="/home/datawork-lpba/Prymnesium/PrymneTranscripto/RNA-longReads-fev25/Prymesium_cDNA_24fev25.bam"

# Création des dossiers
mkdir -p "$RESULT_FOLDER"
mkdir -p "$LOG_FOLDER"

# Suppression de l'ancien fichier final s'il existe
if [[ -f "${FINAL_OUTPUT}" ]]; then
    rm -f "${FINAL_OUTPUT}"
fi
        
# Conversion BAM en FASTQ et écriture dans le fichier compressé
samtools fastq "$BAM_FILE" | gzip > "${FINAL_OUTPUT}" 2>> "${LOG_FOLDER}/bam_to_fastq_errors.log"
