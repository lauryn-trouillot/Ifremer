#!/bin/bash
#PBS -N rnabloom_L
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/rnabloom/2.0.1/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="rnabloom_${TIMESTAMP}"
FILENAME="Chemin/vers/les/long_reads.fastq.gz"
RESULT_FOLDER="Chemin/vers/le/dossier/rnabloom_${TIMESTAMP}"
LOG_FILE="$RESULT_FOLDER/${NAME}.log"

# Paramètres RNAbloom
THREADS=16
MEMORY=300


mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

# Exécution de RNAbloom
rnabloom -long "$FILENAME" \
            -t $THREADS \
            -mem $MEMORY \
            -outdir "$RESULT_FOLDER" >> "$LOG_FILE" 2>&1

