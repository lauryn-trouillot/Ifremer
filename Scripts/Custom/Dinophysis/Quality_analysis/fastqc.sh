#!/bin/bash
#PBS -N fastqc
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
FASTQ_FILE="/home1/datawork/ltrouill/Ifremer/Data/Rawdata/Dinophysis/LongReadsARN/Dinophysis_cDNA.fastq.gz"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/fastqc"
RESULT_FOLDER="/home1/scratch/ltrouill/fastqc_$(date +%Y%m%d_%H%M%S)"

# Création des dossiers
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

. /appli/bioinfo/fastqc/0.12.1/env.sh

for FILE in "${FASTQ_FILE[@]}"; do
    fastqc -o "${RESULT_FOLDER}" -f fastq "${FILE}" -t 15 --memory 3750 2>> "${LOG_FOLDER}/fastqc_$(date +%Y%m%d_%H%M%S).log"
done
