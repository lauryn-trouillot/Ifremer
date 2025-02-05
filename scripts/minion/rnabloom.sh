#!/bin/bash
#PBS -N rnabloom
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
 . /appli/bioinfo/rnabloom/2.0.1/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_rnabloom"
FILENAME="/home1/datawork/ltrouill/ifremer/data/rawdata/minion/Karlodinium_cDNA.fastq.gz"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/rnabloom_errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/rnabloom_${TIMESTAMP}"
LOG_FILE="$LOG_FOLDER/${TIMESTAMP}_${NAME}_pipeline.log"
READS_FOLDER="/home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

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

rnabloom -long "$FILENAME" -t 15 -outdir "$RESULT_FOLDER" -sef "$LEFT_READS" -ser "$RIGHT_READS" >> "$LOG_FILE" 2>&1