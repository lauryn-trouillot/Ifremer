#!/bin/bash
#PBS -N transrate_alignment
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=60gb
#PBS -l walltime=72:00:00

set -e  # Arrêter en cas d'erreur

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialisation des dossiers et logs
CHEMIN="/home1/datawork/ltrouill/ifremer/"
LOG_FOLDER="${CHEMIN}errors/transrate"
OUTPUT_FOLDER="${CHEMIN}results/transrate/transrate_alignment_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_FOLDER" "$OUTPUT_FOLDER"
LOGFILE="${LOG_FOLDER}/transrate_alignment_$(date +%Y%m%d_%H%M%S).log"

echo "=== Début du script: $(date) ===" >"$LOGFILE"

# Variables
FILENAME="${CHEMIN}results/illumina/Trinity_20241128/Karlodinium_trinity_20241128_225603.Trinity.fasta"
EXCLUDE="2|5|8|13|14|18"

# Création des listes de fichiers de lecture
echo "Création des listes de fichiers de lecture..." >>"$LOGFILE"
LEFT_READS=$(ls /home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence/*_R1.fastq.gz | grep -Ev "(${EXCLUDE})_R1.fastq.gz" | tr '\n' ',')
RIGHT_READS=$(ls /home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence/*_R2.fastq.gz | grep -Ev "(${EXCLUDE})_R2.fastq.gz" | tr '\n' ',')

# Suppression des virgules finales
LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

# Vérification des fichiers d'entrée
if [ ! -f "$FILENAME" ]; then
    echo "Erreur : Le fichier transcriptome $FILENAME est introuvable !" >>"$LOGFILE"
    exit 1
fi

if [ -z "$LEFT_READS" ] || [ -z "$RIGHT_READS" ]; then
    echo "Erreur : Aucun fichier FASTQ trouvé pour l'alignement !" >>"$LOGFILE"
    exit 1
fi

echo "Fichier transcriptome trouvé : $FILENAME" >>"$LOGFILE"
echo "Fichiers de lecture utilisés : " >> "$LOGFILE"
echo "LEFT_READS: $LEFT_READS" >> "$LOGFILE"
echo "RIGHT_READS: $RIGHT_READS" >> "$LOGFILE"

# Chargement des modules transrate et correction de l'affinité CPU
echo "Chargement de l'environnement transrate..." >>"$LOGFILE"
. /appli/bioinfo/transrate/1.0.3/env.sh

# Alignement des lectures avec gestion des erreurs
echo "---------- Début de l'alignement transrate ---------- " >>"$LOGFILE"
transrate --assembly "$FILENAME" \
          --left "$LEFT_READS" \
          --right "$RIGHT_READS" \
          --threads 15 \
          --loglevel debug \
          --output "$OUTPUT_FOLDER" >> "$LOGFILE" 2>&1
          
if [ $? -ne 0 ]; then
    echo "Erreur : Transrate a échoué !" >> "$LOGFILE"
    exit 1
fi

echo "=== Fin du script : $(date) ===" >>"$LOGFILE"
