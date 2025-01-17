#!/bin/bash
#PBS -N bowtie2_alignment
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
CHEMIN="/home1/datawork/ltrouill/ifremer/"
LOG_FOLDER="${CHEMIN}errors/bowtie2"
OUTPUT_FOLDER="/home1/scratch/ltrouill/bowtie2_alignment_$(date +%Y%m%d_%H%M%S)"

# Création des dossiers si nécessaires
mkdir -p "$LOG_FOLDER"
mkdir -p "$OUTPUT_FOLDER"

# Initialisation du fichier log
LOGFILE="${LOG_FOLDER}/bowtie2_alignment_$(date +%Y%m%d_%H%M%S).log"

# Indiquer le début du log
echo "=== Début du script: $(date) ===" >"$LOGFILE"

# Variables
FILENAME="${CHEMIN}results/illumina_minion/rnaSPADES/Karlodinium_rnaspade_20250110_155148/transcripts_R.fasta"
EXCLUDE="2|5|8|13|14|18" #"1|3|4|6|7|9|10|11|16|17"

# Création des listes de fichiers de lecture
echo "Création des listes de fichiers de lecture..." >>"$LOGFILE"
LEFT_READS=$(ls /home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence/*_R1.fastq.gz | grep -Ev "(${EXCLUDE})_R1.fastq.gz" | tr '\n' ',')
RIGHT_READS=$(ls /home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence/*_R2.fastq.gz | grep -Ev "(${EXCLUDE})_R2.fastq.gz" | tr '\n' ',')

# Suppression des virgules finales
LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

echo "LEFT_READS: $LEFT_READS" >>"$LOGFILE"
echo "RIGHT_READS: $RIGHT_READS" >>"$LOGFILE"

# Vérification des fichiers d'entrée
if [ ! -f "$FILENAME" ]; then
    echo "Erreur : Le fichier transcriptome $FILENAME est introuvable !" >>"$LOGFILE"
    exit 1
fi
echo "Fichier transcriptome trouvé : $FILENAME" >>"$LOGFILE"

# Chargement des modules Bowtie2
echo "Chargement de l'environnement Bowtie2..." >>"$LOGFILE"
. /appli/bioinfo/bowtie2/2.5.4/env.sh

# Construction de l'index Bowtie2
echo " ------------ Construction de l'index Bowtie2 ----------" >>"$LOGFILE"
INDEX_PREFIX="${OUTPUT_FOLDER}/rnaSPADES_index"
bowtie2-build "$FILENAME" "$INDEX_PREFIX"

echo " ------------ Construction terminé ----------" >>"$LOGFILE"

# Alignement des lectures
echo "---------- Début de l'alignement Bowtie2 ----------" >>"$LOGFILE"
bowtie2 -p 15 --no-unal -q -k 20 -x "$INDEX_PREFIX" -1 "$LEFT_READS" -2 "$RIGHT_READS" \
    2>"${OUTPUT_FOLDER}/align_stats.txt"

# Afficher les statistiques d'alignement
echo " ---------- Statistiques d'alignement ----------" >>"$LOGFILE"
cat "${OUTPUT_FOLDER}/align_stats.txt" >>"$LOGFILE"

# Indiquer la fin du script
echo "=== Fin du script : $(date) ===" >>"$LOGFILE"
