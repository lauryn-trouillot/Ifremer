#!/bin/bash
#PBS -N pilon
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=100gb
#PBS -l walltime=100:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"


# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="pilon_${TIMESTAMP}"
TRANSCRIPTOME="/path/to/Transcriptome.fasta"
SHORT_READS="/pah/to/short_reads_folder"
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder"

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

LOGFILE="$LOG_FOLDER/${NAME}.log" 

echo "Étape 1 : Indexer le transcriptome avec STAR" >> "$LOGFILE"

. /appli/bioinfo/star/2.7.10b/env.sh

STAR --runMode genomeGenerate \
    --genomeDir "$RESULT_FOLDER/star_index" \
    --genomeFastaFiles "$TRANSCRIPTOME" \
    --runThreadN 16 >> "$LOGFILE" 2>&1

echo  "Étape 2 : Aligner les short reads avec STAR" >> "$LOGFILE"

STAR --genomeDir "$RESULT_FOLDER/star_index" \
    --readFilesIn "$SHORT_READS/R1.fastq.gz" "$SHORT_READS/R2.fastq.gz" \
    --readFilesCommand zcat \
    --runThreadN 16 \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix "$RESULT_FOLDER/output_" >> "$LOGFILE" 2>&1

echo "Étape 3 : Indexer le fichier BAM pour Pilon" >> "$LOGFILE"

. /appli/bioinfo/samtools/1.19.2/env.sh

samtools index "$RESULT_FOLDER/output_Aligned.sortedByCoord.out.bam"

. appli/bioinfo/pilon/1.24/env.sh

pilon --genome $TRANSCRIPTOME \
    --frags "$RESULT_FOLDER/output_Aligned.sortedByCoord.out.bam" \
    --output "$RESULT_FOLDER/polished_assembly" >> "$LOGFILE" 2>&1


