#!/bin/bash
#PBS -N rnabloom
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/rnabloom/2.0.1/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_rnabloom_short"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/rnabloom_errors/"
RESULT_FOLDER_BASE="/home1/scratch/ltrouill/rnabloom_short_${TIMESTAMP}"
LOG_FILE="$LOG_FOLDER/${TIMESTAMP}_${NAME}_pipeline.log"
READS_FOLDER="/home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence"
RESULT_FOLDER="$RESULT_FOLDER_BASE"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER_BASE"

# Exclure certains fichiers de lecture Illumina
EXCLUDE="2|5|8|13|14|18" # Ajouter les indices des échantillons à exclure

# Combiner les fichiers de lecture Illumina en excluant certains échantillons
for file in "$READS_FOLDER"/*_R1.fastq.gz; do
    if [[ ! "$file" =~ _($EXCLUDE)_ ]]; then
        echo "Processing $file" >> "$LOG_FILE"
        zcat "$file" >> "$RESULT_FOLDER/LEFT.fastq"
    fi
done

for file in "$READS_FOLDER"/*_R2.fastq.gz; do
    if [[ ! "$file" =~ _($EXCLUDE)_ ]]; then
        echo "Processing $file" >> "$LOG_FILE"
        zcat "$file" >> "$RESULT_FOLDER/RIGHT.fastq"
    fi
done

# Définir les variables de lecture
LEFT_READS="$RESULT_FOLDER/LEFT.fastq"
RIGHT_READS="$RESULT_FOLDER/RIGHT.fastq"

# Exécuter rnabloom avec différentes valeurs de k
rnabloom -sef "$LEFT_READS" -ser "$RIGHT_READS" \
            -t 16 \
            -mem 300 \
            -outdir "$RESULT_FOLDER" \
            -sensitive \
            -e 3 -grad 0.3 \
            -p 0.95 >> "$LOG_FILE" 2>&1
