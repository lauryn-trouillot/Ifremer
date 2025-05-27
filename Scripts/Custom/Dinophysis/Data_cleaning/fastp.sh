#!/bin/bash
#PBS -N fastp
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=40gb
#PBS -l walltime=10:00:00

# Filtration short reads brute

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/fastp/0.23.2/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="fastp_${TIMESTAMP}"
SHORT_READS_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Rawdata/Dinophysis/ShortReadsARN"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Karlodinium/Errors/fastp"
RESULT_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Dinophysis/fastp_${TIMESTAMP}"
REPORT_FOLDER="$RESULT_FOLDER/Report/"
LOG_FILE="$LOG_FOLDER/${NAME}.log"

# Paramètres fastp
AV_QUALITY=30
LENGTH=100

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$REPORT_FOLDER"

for R1 in $SHORT_READS_FOLDER/*_1.fastq.gz; do
    R2=${R1/_1/_2}
    base=$(basename "${R1%_1.fastq.gz}")
    
    echo "Nettoyage des reads : ${base} -- $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"
    
    fastp -i "$R1" -I "$R2" \
        -l "$LENGTH" \
        -e "$AV_QUALITY" \
        --low_complexity_filter \
        --trim_poly_g \
        -h "$REPORT_FOLDER/${base}_fastp_report.html" -j "$REPORT_FOLDER/${base}_fastp_report.json" \
        -o "$RESULT_FOLDER/${base}_R1.cleaned.fastq.gz" -O "$RESULT_FOLDER/${base}_R2.cleaned.fastq.gz" >> "$LOG_FILE" 2>&1

    echo "Nettoyage des reads : ${base} terminé -- $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"
done
