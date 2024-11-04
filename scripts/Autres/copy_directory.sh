#!/bin/bash
#PBS -N copy_files
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=48:00:00

# Définition des variables de chemins
SOURCE_DIR="/home1/scratch/ltrouill/ifremer"
DEST_DIR="/home1/datawork/ltrouill/ifremer"
RESULTS_DIR="$SOURCE_DIR/results_1"
ARCHIVE_NAME="result_1.tar.gz"
ERRORS_DIR="$SOURCE_DIR/errors"
LOG_FILES=("20241030_125012_Karlodinium_trinity.log" "20241022_092606_Karlodinium_trinity.log")


# Création de l'archive tar.gz du répertoire spécifié
tar -czvf "$SOURCE_DIR/$ARCHIVE_NAME" "$RESULTS_DIR"

# Copie de l'archive vers le répertoire de destination
cp "$SOURCE_DIR/$ARCHIVE_NAME" "$DEST_DIR"


# Copie des fichiers de log vers le répertoire de destination
for log_file in "${LOG_FILES[@]}"; do
    cp "$ERRORS_DIR/$log_file" "$DEST_DIR/errors/"
done

echo "Copie terminée avec succès."
