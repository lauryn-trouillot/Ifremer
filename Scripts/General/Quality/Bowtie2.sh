#!/bin/bash
#PBS -N bowtie2_alignment
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# filepath: /home1/datawork/ltrouill/ifremer/SCRIPTS/Quality/bowtie_analysis.sh
cd "${PBS_O_WORKDIR}"

####################################
# Variables
####################################
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder/bowtie2_alignment_$(date +%Y%m%d_%H%M%S)"
FILENAME="/path/to/assembly_file"
READS_FOLDER="/path/to/your/reads_folder"
LOGFILE="${LOG_FOLDER}/bowtie2_alignment_$(date +%Y%m%d_%H%M%S).log"

# Paramètres Bowtie2
BOWTIE2_THREADS=15
BOWTIE2_MAX_ALIGN=20
BOWTIE2_OPTIONS="--no-unal -q"

####################################
# Création des répertoires
####################################
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

# Début du log
echo "=== Début du script : $(date) ===" >"$LOGFILE"
echo "Résultats dans : $RESULT_FOLDER" >>"$LOGFILE"

# Vérification des reads
LEFT_READS=$(ls "${READS_FOLDER}"/*_R1.fastq.gz 2>/dev/null | tr '\n' ',')
RIGHT_READS=$(ls "${READS_FOLDER}"/*_R2.fastq.gz 2>/dev/null | tr '\n' ',')

LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

####################################
# Chargement de Bowtie2 et indexage
####################################
echo "Chargement de Bowtie2..." >>"$LOGFILE"
. /appli/bioinfo/bowtie2/2.5.4/env.sh

echo "--- Construction de l'index Bowtie2 ---" >>"$LOGFILE"
INDEX_PREFIX="${RESULT_FOLDER}/transcript_index"
bowtie2-build "$FILENAME" "$INDEX_PREFIX" >>"$LOGFILE" 2>&1
echo "Construction terminée" >>"$LOGFILE"

####################################
# Alignement
####################################
echo "--- Début de l'alignement Bowtie2 ---" >>"$LOGFILE"

bowtie2 \
  -p "$BOWTIE2_THREADS" \
  $BOWTIE2_OPTIONS \
  -k "$BOWTIE2_MAX_ALIGN" \
  -x "$INDEX_PREFIX" \
  -1 "$LEFT_READS" \
  -2 "$RIGHT_READS" \
  2>"${RESULT_FOLDER}/align_stats.txt"

echo "Statistiques d'alignement :" >>"$LOGFILE"
cat "${RESULT_FOLDER}/align_stats.txt" >>"$LOGFILE"

echo "=== Fin du script : $(date) ===" >>"$LOGFILE"
