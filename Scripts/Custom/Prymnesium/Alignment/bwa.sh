#!/bin/bash
#PBS -N bwa
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
NAME="Prymnesium"
FASTQ_FOLDER="/home/ref-bioinfo/ifremer/phytox/p-parvum-mixotrophie/data/raw-sequence/"
REF_FASTA="/home1/scratch/ltrouill/rnabloom_20250402_082249/rnabloom.transcripts.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/bwa/"
RESULT_FOLDER="/home1/scratch/ltrouill/bwa_$(date +%Y%m%d_%H%M%S)"

# Vérification de l'existence d'un dossier bwa_20**
EXISTING_FOLDER=$(ls -d /home1/scratch/ltrouill/bwa_20* 2>/dev/null | tail -n 1)

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
     bwa mem $REF_FASTA $FASTQ_FOLDER/AA_R1.fastq.gz $FASTQ_FOLDER/AA_R2.fastq.gz > "$RESULT_FOLDER/${NAME}_short.sam" 2>&1 | tee -a "$LOG_FILE"
fi

. /appli/bioinfo/samtools/1.9/env.sh

if [ ! -f "$RESULT_FOLDER/${BASENAME}.bam" ]; then
    samtools view -bo "$RESULT_FOLDER/${NAME}_short.sam" -o "$RESULT_FOLDER/"$RESULT_FOLDER/${NAME}_short.bam" " 2>&1 | tee -a "$LOG_FILE"
fi

samtools sort "$RESULT_FOLDER/${NAME}_short.bam" -o "$RESULT_FOLDER/${NAME}_sorted.bam" >>"$LOGFILE" 2>&1

samtools index "$RESULT_FOLDER/${NAME}_sorted.bam" >>"$LOGFILE" 2>&1

SUMMARY_FILE="${RESULT_FOLDER}/${NAME}_alignment_summary.txt"

samtools flagstat "$RESULT_FOLDER/${NAME}_sorted.bam" > "$SUMMARY_FILE" 2>> "$LOGFILE"
