#!/bin/bash
#PBS -N rnabloom_S
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
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_forlder"
LOG_FILE="$LOG_FOLDER/${TIMESTAMP}_${NAME}.log"
READS_FOLDER="/path/to/your/reads_folder"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

# Combiner les fichiers de lecture Illumina en excluant certains échantillons
for file in "$READS_FOLDER"/*_R1.fastq.gz; do
        echo "Processing $file" >> "$LOG_FILE"
        zcat "$file" >> "$RESULT_FOLDER/LEFT.fastq"
done

for file in "$READS_FOLDER"/*_R2.fastq.gz; do
        echo "Processing $file" >> "$LOG_FILE"
        zcat "$file" >> "$RESULT_FOLDER/RIGHT.fastq"
done

# Définir les variables de lecture
LEFT_READS="$RESULT_FOLDER/LEFT.fastq"
RIGHT_READS="$RESULT_FOLDER/RIGHT.fastq"

# Paramètres RNAbloom
THREADS=16
MEMORY=300
KMER_SIZE=20
SENSITIVITY="--sensitive"
ERROR_RATE=3
GRADIENT=0.3
PROBABILITY=0.95

# Execution de RNAbloom
rnabloom -sef "$LEFT_READS" -ser "$RIGHT_READS" \
            -t $THREADS \
            -mem $MEMORY \
            -outdir $RESULT_FOLDER \
            -SENSITIVITY \
            -e $ERROR_RATE \
            -grad $GRADIENT \
            -p $PROBABILITY >> "$LOG_FILE" 2>&1
