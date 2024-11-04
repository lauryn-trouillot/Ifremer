#!/bin/bash
#PBS -N copy_files
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=48:00:00

# D�finition des variables de chemins
SOURCE_DIR="/home1/scratch/ltrouill/ifremer"
DEST_DIR="/home1/datawork/ltrouill/ifremer"
RESULTS_DIR="$SOURCE_DIR/results_1"
ARCHIVE_NAME="result_1.tar.gz"
ERRORS_DIR="$SOURCE_DIR/errors"
LOG_FILES=("20241030_125012_Karlodinium_trinity.log" "20241022_092606_Karlodinium_trinity.log")


# Cr�ation de l'archive tar.gz du r�pertoire sp�cifi�
tar -czvf "$SOURCE_DIR/$ARCHIVE_NAME" "$RESULTS_DIR"

# Copie de l'archive vers le r�pertoire de destination
cp "$SOURCE_DIR/$ARCHIVE_NAME" "$DEST_DIR"


# Copie des fichiers de log vers le r�pertoire de destination
for log_file in "${LOG_FILES[@]}"; do
    cp "$ERRORS_DIR/$log_file" "$DEST_DIR/errors/"
done

echo "Copie termin�e avec succ�s."
