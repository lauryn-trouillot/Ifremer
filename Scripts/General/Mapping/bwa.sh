#!/bin/bash
#PBS -N bwa
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Pour aligner des short reads issu du séquencage de génome sur un genome 

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
FASTQ_FILE="/path/to/fastq_file"
REF_FASTA="/path/to/Ref_file"
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder/bwa_$(date +%Y%m%d_%H%M%S)"

# Vérification de l'existence d'un dossier bwa_20**
EXISTING_FOLDER=$(ls -d /path/to/result_folder/bwa_20* 2>/dev/null | tail -n 1)

if [ -n "$EXISTING_FOLDER" ]; then
    echo "Un dossier existant a été trouvé : $EXISTING_FOLDER"
    RESULT_FOLDER="$EXISTING_FOLDER"
else
    # Création des dossiers
    mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"
fi

. /appli/bioinfo/bwa/0.7.17/env.sh

BASENAME=$(basename "$FASTQ_FOLDER")

# Redirection des logs
LOG_FILE="$LOG_FOLDER/bwa_$(date +%Y%m%d_%H%M%S).log"

echo "Début de la pipeline : bwa" > $LOG_FILE

cd $RESULT_FOLDER

if [ ! -f "$RESULT_FOLDER/${BASENAME}.sam" ]; then
     bwa index $REF_FASTA 2>&1 | tee -a "$LOG_FILE"
fi

if [ ! -f "$RESULT_FOLDER/${BASENAME}.sam" ]; then
     bwa mem $REF_FASTA $FASTQ_FOLDER/R1.fastq.gz $FASTQ_FOLDER/R2.fastq.gz > "$RESULT_FOLDER/name.sam" 2>&1 | tee -a "$LOG_FILE"
fi

. /appli/bioinfo/samtools/1.9/env.sh

if [ ! -f "$RESULT_FOLDER/${BASENAME}.bam" ]; then
    samtools view -bo "$RESULT_FOLDER/name.sam" -o "$RESULT_FOLDER/name.bam" 2>&1 | tee -a "$LOG_FILE"
fi