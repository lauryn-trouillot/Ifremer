#!/bin/bash
#PBS -N fastplong
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=100gb
#PBS -l walltime=10:00:00

# Filtration short reads brute

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

. /appli/bioinfo/fastplong/0.2.2/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="fastplong_${TIMESTAMP}"
LONG_READS="Chemin/vers/les/long_reads.fastq.gz"
LOG_FOLDER="Chemin/vers/le/dossier/logs/fastplong"
RESULT_FOLDER="Chemin/vers/le/dossier/fastplong_${TIMESTAMP}"
RESULT_FILE="$RESULT_FOLDER/output.fastq"
REPORT_FOLDER="$RESULT_FOLDER/Report/"
LOG_FILE="$LOG_FOLDER/${NAME}.log"


mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$REPORT_FOLDER"

base=$(basename "${LONG_READS}")

echo "Nettoyage des Long reads : ${base} -- $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"

fastplong --in "$LONG_READS" \
        --out "$RESULT_FILE" \
        --failed_out "$RESULT_FOLDER/Failed_reads.fastq.gz" \
        --html "$REPORT_FOLDER/Report.html" \
        -j "$REPORT_FOLDER/Report.json" \
        --n_base_limit 10 \
        --mean_qual 20 \
        --qualified_quality_phred 20 \
        --unqualified_percent_limit 40 \
        --length_required 200 \
        --length_limit 10000 \
        --adapter_fasta "Chemin/vers/le/dossier/adapters.fasta" \
        --trimming_extension 5 \
        --trim_front 0 \
        --trim_tail 0 2>> "$LOG_FILE"

echo "Nettoyage des reads : ${base} terminé -- $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"

