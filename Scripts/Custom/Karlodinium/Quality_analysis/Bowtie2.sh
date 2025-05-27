#!/bin/bash
#PBS -N bowtie2_alignment
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=72:00:00

cd "${PBS_O_WORKDIR}"

####################################
# Variables
####################################
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/Bowtie2"
RESULT_FOLDER="/home1/scratch/ltrouill/bowtie2_alignment_$(date +%Y%m%d_%H%M%S)"
FILENAME="/home1/datawork/ltrouill/Ifremer/Results/Karlodinium/low_expression/transcripts_analysis_20250512_142253/filtered_transcripts.fasta"
READS_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Karlodinium/Short_reads/fastp_20250414_121346"
LOGFILE="${LOG_FOLDER}/bowtie2_alignment_$(date +%Y%m%d_%H%M%S).log"
FASTQ=False

BOWTIE2_THREADS=15
BOWTIE2_OPTIONS="--no-unal -q"

####################################
# Création des répertoires
####################################

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"


# Début du log
echo "=== Début du script : $(date) ===" >"$LOGFILE"
echo "Résultats dans : $RESULT_FOLDER" >>"$LOGFILE"

# Conversion FASTQ → FASTA si nécessaire
if [[ "$FASTQ" == "True" ]]; then
    echo "Conversion de ${FILENAME} en FASTA..." >>"$LOGFILE"
    . /appli/bioinfo/seqtk/1.4/env.sh
    seqtk seq -a "${FILENAME}" > "${RESULT_FOLDER}/transcriptome.fasta" 2>>"$LOGFILE"
    if [[ $? -ne 0 ]]; then
        echo "Erreur : la conversion du fichier FASTQ en FASTA a échoué." >>"$LOGFILE"
        exit 1
    fi
    FILENAME="${RESULT_FOLDER}/transcriptome.fasta" 
fi


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

for i in $(seq 1 18); do
    echo "Alignement de l'échantillon $i..." >>"$LOGFILE"
    
    bowtie2 \
      -p "$BOWTIE2_THREADS" \
      $BOWTIE2_OPTIONS \
      -x "$INDEX_PREFIX" \
      -1 "$READS_FOLDER/${i}_R1.cleaned.fastq.gz" \
      -2 "$READS_FOLDER/${i}_R2.cleaned.fastq.gz" \
      -S "$RESULT_FOLDER/align_${i}.sam" >> "$LOGFILE" 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de l'alignement de l'échantillon $i" >>"$LOGFILE"
    else
        echo "Alignement de l'échantillon $i terminé avec succès." >>"$LOGFILE"
    fi
done
