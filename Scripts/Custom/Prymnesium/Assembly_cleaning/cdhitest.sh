#!/bin/bash
#PBS -N cluster
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="cluster_${TIMESTAMP}"
ASSEMBLY_FILE="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/low_expression/transcripts_analysis_20250424_212355/filtered_transcripts.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/Clustering/"
LOG_FILE="$LOG_FOLDER/${NAME}.log"
RESULT_FOLDER="/home1/scratch/ltrouill/${NAME}"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" 

THRESHOLD_VALUE=10
SIMILARITY_VALUE=0.98

CLUSTER_FILE="$RESULT_FOLDER/cluster_${SIMILARITY_VALUE}_${THRESHOLD_VALUE}.fasta"

. /appli/bioinfo/cd-hit/4.8.1/env.sh

cd-hit-est -i "$ASSEMBLY_FILE" \
            -o "$CLUSTER_FILE" \
            -c "$SIMILARITY_VALUE" \
            -n "$THRESHOLD_VALUE" \
            -p 1 \
            -d 0 \
            -b 3 \
            -M 300000 \
            -T 15 >> "$LOG_FILE" 2>&1
