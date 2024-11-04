#!/bin/bash 
#PBS -N RATTLE_assembly
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=250:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Chargement de l'environnement sp�cifique pour Rattle
. /appli/bioinfo/rattle/1.0.0/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_RATTLE"
CHEMIN="/home/datawork-lpba/karlodinium/Transcriptome/RawDataTEMP/Karlodinium_RNAref-2/karlodinium_RNAref-2/20240930_1630_MN20979_ASI088_0cdfc4f6/fastq_pass/"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/ifremer/result_RATTLE"
CLUSTERS_FOLDER="$RESULT_FOLDER/clusters"
ARCHIVE_NAME="${RESULT_FOLDER}.tar.gz"

# Cr�ation des dossiers de log et de r�sultats s'ils n'existent pas
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$CLUSTERS_FOLDER"

# Obtenir tous les fichiers FASTQ compress�s dans le r�pertoire
READS=$(ls "$CHEMIN"/*.fastq.gz | tr '\n' ',' | sed 's/,$//')

# �tape 1 : Clustering des reads
rattle cluster \
    -i "$READS" \
    --iso \
    -t 20 \
    -o "$RESULT_FOLDER" \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_cluster.log"

# �tape 2 : Extraction des fichiers FASTQ par cluster
rattle extract_clusters \
    -i "$READS" \
    -c "$RESULT_FOLDER/transcripts.out" \
    -o "$CLUSTERS_FOLDER" \
    --fastq \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_extract_clusters.log"

# �tape 3 : Correction des reads en utilisant les clusters d'isoformes
rattle correct \
    -i "$READS" \
    -c "$RESULT_FOLDER/clusters.out" \
    -t 20 \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_correct.log"

# �tape 4 : Polissage des s�quences consensus pour le transcriptome final
rattle polish \
    -i "$RESULT_FOLDER/corrected.fq" \
    -t 20 \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_polish.log"

# D�chargement de l'environnement Rattle
/appli/bioinfo/rattle/1.0.0/delenv.sh

# Compression des r�sultats
tar -czvf "$ARCHIVE_NAME" -C "$RESULT_FOLDER" .

# Copie des r�sultats compress�s vers le dossier final
cp "$ARCHIVE_NAME" "/home1/datawork/ltrouill/ifremer/"
