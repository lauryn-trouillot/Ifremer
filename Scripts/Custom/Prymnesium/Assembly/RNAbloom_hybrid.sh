#!/bin/bash
#PBS -N rnabloom_L
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/rnabloom/2.0.1/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="rnabloom_${TIMESTAMP}"
LR_FILE="/home/datawork-lpba/Prymnesium/PrymneTranscripto/RNA-longReads-fev25/Galaxy43_Prymnesium_cDNA_Porechop_Qualite.fastq"
READS_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Prymnesium/Short_reads/fastp_20250407_081434"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/rnabloom"
RESULT_FOLDER="/home1/scratch/ltrouill/${NAME}"
LOG_FILE="$LOG_FOLDER/${NAME}.log"

# Paramètres RNAbloom
THREADS=16
MEMORY=300
KMER_SIZE=20
SENSITIVITY="-sensitive"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

zcat "$READS_FOLDER/AA_R1.cleaned.fastq.gz" >> "$RESULT_FOLDER/SEF.fastq"
zcat "$READS_FOLDER/AA_R2.cleaned.fastq.gz" >> "$RESULT_FOLDER/SER.fastq"

# Exécution de RNAbloom
rnabloom -long "$LR_FILE" \
            -sef "$RESULT_FOLDER/SEF.fastq" \
            -ser "$RESULT_FOLDER/SER.fastq" \
            -t $THREADS \
            -mem $MEMORY \
            -outdir "$RESULT_FOLDER" \
            -k $KMER_SIZE \
            $SENSITIVITY >> "$LOG_FILE" 2>&1

