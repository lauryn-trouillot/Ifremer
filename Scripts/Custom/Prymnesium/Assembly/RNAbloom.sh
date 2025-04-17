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
FILENAME="/home/datawork-lpba/Prymnesium/PrymneTranscripto/RNA-longReads-fev25/Galaxy43-[Prymnesium_cDNA Porechop OK Qualite Ok].fastq"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/rnabloom"
RESULT_FOLDER="/home1/scratch/ltrouill/rnabloom_${TIMESTAMP}"
LOG_FILE="$LOG_FOLDER/${NAME}.log"

# Paramètres RNAbloom
THREADS=16
MEMORY=300
KMER_SIZE=20
SENSITIVITY="-sensitive"
ERROR_RATE=3
GRADIENT=0.3
PROBABILITY=0.95

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

# Exécution de RNAbloom
rnabloom -long "$FILENAME" \
            -t $THREADS \
            -mem $MEMORY \
            -outdir "$RESULT_FOLDER" \
            -k $KMER_SIZE \
            $SENSITIVITY \
            -e $ERROR_RATE \
            -grad $GRADIENT \
            -p $PROBABILITY >> "$LOG_FILE" 2>&1

