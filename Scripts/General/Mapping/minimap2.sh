#!/bin/bash
#PBS -N minimap
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
FASTQ_FILE="/path/to/fastq_file"
REF_FASTA="/path/to/Ref_file"
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder/minimap2_$(date +%Y%m%d_%H%M%S)"

# Vérification de l'existence d'un dossier minimap2_20**
EXISTING_FOLDER=$(ls -d /home1/scratch/ltrouill/minimap2_20* 2>/dev/null | tail -n 1)

if [ -n "$EXISTING_FOLDER" ]; then
    echo "Un dossier existant a été trouvé : $EXISTING_FOLDER"
    RESULT_FOLDER="$EXISTING_FOLDER"
else
    # Création des dossiers
    mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"
fi

. /appli/bioinfo/minimap2/2.28/env.sh

BASENAME=$(basename "$FASTQ_FILE")

# Redirection des logs
LOG_FILE="$LOG_FOLDER/minimap2_$(date +%Y%m%d_%H%M%S).log"

echo "Début de la pipeline : minimap2" > $LOG_FILE

BASENAME=$(basename "$FASTQ_FILE" .fastq.gz)

if [ ! -f "$RESULT_FOLDER/${BASENAME}.sam" ]; then
    minimap2 -ax splice -t 6 $REF_FASTA $FASTQ_FILE > "$RESULT_FOLDER/${BASENAME}.sam" 2>&1 | tee -a "$LOG_FILE"
fi

. /appli/bioinfo/samtools/1.9/env.sh

if [ ! -f "$RESULT_FOLDER/${BASENAME}.bam" ]; then
    samtools sort "$RESULT_FOLDER/${BASENAME}.sam" -o "$RESULT_FOLDER/${BASENAME}.bam" 2>&1 | tee -a "$LOG_FILE"
fi

if [ ! -f "$RESULT_FOLDER/${BASENAME}.bam.bai" ]; then
    samtools index "$RESULT_FOLDER/${BASENAME}.bam" 2>&1 | tee -a "$LOG_FILE"
fi