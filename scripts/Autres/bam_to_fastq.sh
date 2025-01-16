#!/bin/bash 
#PBS -N BAM_to_fastq
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

. /appli/bioinfo/samtools/1.19.2/env.sh

# Déclaration des variables
CHEMIN="/home/datawork-lpba/karlodinium/Transcriptome/RawDataTEMP"
RESULT_FOLDER="/home1/datawork/ltrouill/ifremer/data/rawdata/minion/"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors"
FINAL_OUTPUT="${RESULT_FOLDER}/Karlodinium_cDNA.fastq"

BAM_FILES=(
    "$CHEMIN/Karlodinium_cDNA_20240930_1/Karlodinium_cDNA_20240930_1/20240930_1442_MN18022_ASH731_e4577526/Dorado_duplex/Karlodinium_RNAref_1_pod5_output.bam"
    "$CHEMIN/Karlodinium_cDNA_20240930_2/Karlodinium_cDNA_20240930_2/20240930_1630_MN20979_ASI088_0cdfc4f6/Dorado_duplex/Karlodinium_RNAref_2_pod5_output.bam"
    "$CHEMIN/Karlodinium_cDNA_20241122/Karlodinium_cDNA_20241122/20241122_1446_MN18022_FAZ16076_fa62a9fc/Dorado_duplex/Karlodinium-cDNA-22-11.bam"
    "$CHEMIN/Karlodinium_cDNA_20241126/Karlodinium_cDNA_20241126/20241126_1213_MN18022_FAY53970_63d7df7b/Dorado_duplex/pod5_output.bam"
    "$CHEMIN/Karlodinium-cDNA-Fongl26_11/Karlodinium-cDNA-Fongl26_11/20241126_1214_MN48089_ASH658_327a6319/Dorado_duplex/Karlodinium-cDNA-Fongl26_11_pod5_output.bam"
)

# Création des dossiers
mkdir -p "${RESULT_FOLDER}"
mkdir -p "${LOG_FOLDER}"

# Dossier de sortie pour les fichiers FASTQ individuels
INDIVIDUAL_FASTQ_FOLDER="${RESULT_FOLDER}/individual_fastq"
mkdir -p "$INDIVIDUAL_FASTQ_FOLDER"

# Suppression de l'ancien fichier final s'il existe
if [[ -f "${FINAL_OUTPUT}" ]]; then
    rm -f "${FINAL_OUTPUT}"
fi

# Traitement des fichiers BAM
for file in "${BAM_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Traitement de : $file"
        # Nom du dossier parent
        PARENT_DIR=$(basename "$(dirname "$(dirname "$(dirname "$file")")")")
        
        # Nom du fichier FASTQ individuel
        INDIVIDUAL_FASTQ="${INDIVIDUAL_FASTQ_FOLDER}/${PARENT_DIR}.fastq"
        
        # Conversion BAM en FASTQ et écriture dans le fichier individuel
        samtools fastq "$file" | gzip > "${INDIVIDUAL_FASTQ}.gz" 2>> "${LOG_FOLDER}/bam_to_fastq_errors.log"
        
        # Ajout du contenu du fichier individuel au fichier concaténé
        zcat "${INDIVIDUAL_FASTQ}.gz" >> "$FINAL_OUTPUT"
    else
        echo "Erreur : Fichier BAM introuvable : $file" >> "${LOG_FOLDER}/missing_files.log"
    fi
done
gzip -f "$FINAL_OUTPUT"

echo "Conversion terminée. Les fichiers FASTQ individuels sont dans $INDIVIDUAL_FASTQ_FOLDER et le fichier concaténé est $FINAL_OUTPUT."
