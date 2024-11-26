#!/bin/bash
#PBS -N busco_trinity
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=40gb
#PBS -l walltime=48:00:00

# Chargement de l'environnement de travail
cd ${PBS_O_WORKDIR}

# Chargement de l'environnement BUSCO
. /appli/bioinfo/busco/5.6.1/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="BUSCO_TRINITY_${TIMESTAMP}"
SEQ_FILE="/home1/datawork/ltrouill/ifremer/results/illumina/Karlodinium_trinity.Trinity.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/BUSCO/${NAME}"
ARCHIVE_NAME="${NAME}.tar.gz"

# Création des dossiers
mkdir -p "$RESULT_FOLDER"
mkdir -p "$LOG_FOLDER"

# Commande BUSCO en mode offline avec log
busco -i "${SEQ_FILE}" -o ${NAME} -m transcriptome --offline -f -c 20 \
      -l eukaryota_odb10 \
      2>&1 | tee "${LOG_FOLDER}/${NAME}.log"

# Archivage des résultats
tar -czvf "/home1/scratch/ltrouill/BUSCO/${ARCHIVE_NAME}" -C "/home1/scratch/ltrouill/BUSCO/" "${NAME}"

