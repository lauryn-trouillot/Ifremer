#!/bin/bash
#PBS -N intersect
#PBS -l ncpus=16
#PBS -l walltime=04:00:00
#PBS -l mem=100gb
#PBS -q omp


. /appli/bioinfo/bedtools/2.30.0/env.sh
# Répertoire de travail
cd $PBS_O_WORKDIR

# Fichiers d'entrée
BAM_FILE="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/minimap2/minimap2_20250423_085749/Galaxy43_Prymnesium_cDNA_Porechop_Qualite.bam"
GFF_FILE="/home/datawork-lpba/Prymnesium/PrymneGenomeV1/Prymne_AnnotationV1.gff"
INTERSECT_FOLDER="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/bedtools"
INTERSECT_OUTPUT="$INTERSECT_FOLDER/intersect_result.bed.gz"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/intersect"
LOG_FILE="$LOG_FOLDER/intersect_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$INTERSECT_FOLDER" "$LOG_FOLDER"

echo "Début de l'intersection à $(date)" >> "$LOG_FILE"
bedtools intersect -a "$BAM_FILE" -b "$GFF_FILE"  > "$INTERSECT_OUTPUT" 2>> "$LOG_FILE"
echo "Analyse terminée à $(date). Résultat écrit dans $INTERSECT_OUTPUT" >> "$LOG_FILE"
