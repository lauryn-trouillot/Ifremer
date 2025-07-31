#!/bin/bash
#PBS -N porechop
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=100gb
#PBS -l walltime=24:00:00

FILENAME="Chemin/vers/le/dossier/long_reads.fastq.gz"
LOG_FOLDER="Chemin/vers/le/dossier/logs/porechop"
RESULT_FOLDER="Chemin/vers/le/dossier/porechop_results"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

python3 /home1/datawork/ltrouill/Porechop/porechop-runner.py -i "$FILENAME" \
                                                             -o "$RESULT_FOLDER/output_cleaned.fastq" \
                                                              > "$LOG_FOLDER/porechop.log" 2>&1
