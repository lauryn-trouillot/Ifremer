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
RESULT_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Rawdata/Dinophysis/LongReadsARN"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/BAM_to_fastq/"
FINAL_OUTPUT="${RESULT_FOLDER}/Dinophysis_cDNA.fastq.gz"

# Création des dossiers
mkdir -p "${RESULT_FOLDER}" "${LOG_FOLDER}"

{
  for file in ${RESULT_FOLDER}/*.bam; do 
    samtools fastq "${file}" 2>> "${LOG_FOLDER}/BAM_to_fastq.log" 
  done
} | gzip > "${FINAL_OUTPUT}" 2>> "${LOG_FOLDER}/BAM_to_fastq.log"

echo "Conversion terminée. Le fichier concaténé et compressé est : ${FINAL_OUTPUT}" >> "${LOG_FOLDER}/BAM_to_fastq.log"

