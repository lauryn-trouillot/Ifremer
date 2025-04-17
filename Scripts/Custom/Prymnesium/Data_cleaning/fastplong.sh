#!/bin/bash
#PBS -N fastplonglong
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=40gb
#PBS -l walltime=10:00:00

# Filtration short reads brute

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/fastplong/0.2.2/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="fastplong_${TIMESTAMP}"
LONG_READS="/home/ref-bioinfo/ifremer/phytox/p-parvum-mixotrophie/data/raw-sequence"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/fastplong"
RESULT_FOLDER="/home1/scratch/ltrouill/fastplong_${TIMESTAMP}"
REPORT_FOLDER="$RESULT_FOLDER/Report/"
LOG_FILE="$LOG_FOLDER/${NAME}.log"


mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$REPORT_FOLDER"

base=$(basename "${LONG_READS}")

echo "Nettoyage des Long reads : ${base} -- $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"

fastplong --in "$LONG_READS" \
        --out "$RESULT_FOLDER/" \
        --failed_out "$RESULT_FOLDER/Failed_reads.fastq.gz" \
        --html "$REPORT_FOLDER/Report.html" \
        -j "$REPORT_FOLDER/Report.json" \
        --n_base_limit 10 \
        --mean_qual 30 \
        --qualified_quality_phred 20 \
        --unqualified_percent_limit 40 \
        --length_required 200 \
        --length_limit 10000 \
        --adapter_fasta "/home/gregory/Fastplong/Fastp-Addapters-SansPolyA.fasta" \
        --trimming_extension 5 \
        --trim_front 0 \
        --trim_tail 0 \
        2> "$LOG_FILE"

echo "Nettoyage des reads : ${base} terminé -- $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"

