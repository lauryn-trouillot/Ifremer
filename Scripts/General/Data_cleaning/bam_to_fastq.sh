#!/bin/bash 
#PBS -N BAM_to_fastq
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}" || exit 1
. /appli/bioinfo/samtools/1.19.2/env.sh

# Déclaration des variables
DATA_FOLDER="Chemin/vers/le/dossier/data/"
LOG_FOLDER="Chemin/vers/le/dossier/logs/"
FINAL_OUTPUT="${DATA_FOLDER}/output.fastq.gz"

# Création des dossiers
mkdir -p "${DATA_FOLDER}" "${LOG_FOLDER}"

{
  for file in ${DATA_FOLDER}/*.bam; do
    samtools fastq "${file}" 2>> "${LOG_FOLDER}/BAM_to_fastq.log"
  done
} | gzip > "${FINAL_OUTPUT}" 2>> "${LOG_FOLDER}/BAM_to_fastq.log"

echo "Conversion terminée. Le fichier concaténé et compressé est : ${FINAL_OUTPUT}" >> "${LOG_FOLDER}/BAM_to_fastq.log"

