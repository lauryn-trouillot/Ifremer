#!/bin/bash 
#PBS -N RATTLE_assembly
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=250:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Chargement de l'environnement spécifique pour Rattle
. /appli/bioinfo/rattle/1.0.0/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_RATTLE"
CHEMIN="/home/datawork-lpba/karlodinium/Transcriptome/RawDataTEMP/Karlodinium_RNAref-2/karlodinium_RNAref-2/20240930_1630_MN20979_ASI088_0cdfc4f6/fastq_pass/"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/ifremer/result_RATTLE"
CLUSTERS_FOLDER="$RESULT_FOLDER/clusters"
ARCHIVE_NAME="${RESULT_FOLDER}.tar.gz"

# Création des dossiers de log et de résultats s'ils n'existent pas
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$CLUSTERS_FOLDER"

# Obtenir tous les fichiers FASTQ compressés dans le répertoire
READS=$(ls "$CHEMIN"/*.fastq.gz | tr '\n' ',' | sed 's/,$//')

# Étape 1 : Clustering des reads
rattle cluster \
    -i "$READS" \
    --iso \
    -t 20 \
    -o "$RESULT_FOLDER" \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_cluster.log"

# Étape 2 : Extraction des fichiers FASTQ par cluster
rattle extract_clusters \
    -i "$READS" \
    -c "$RESULT_FOLDER/transcripts.out" \
    -o "$CLUSTERS_FOLDER" \
    --fastq \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_extract_clusters.log"

# Étape 3 : Correction des reads en utilisant les clusters d'isoformes
rattle correct \
    -i "$READS" \
    -c "$RESULT_FOLDER/clusters.out" \
    -t 20 \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_correct.log"

# Étape 4 : Polissage des séquences consensus pour le transcriptome final
rattle polish \
    -i "$RESULT_FOLDER/corrected.fq" \
    -t 20 \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_polish.log"

# Déchargement de l'environnement Rattle
/appli/bioinfo/rattle/1.0.0/delenv.sh

# Compression des résultats
tar -czvf "$ARCHIVE_NAME" -C "$RESULT_FOLDER" .

# Copie des résultats compressés vers le dossier final
cp "$ARCHIVE_NAME" "/home1/datawork/ltrouill/ifremer/"
