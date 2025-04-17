#!/bin/bash
#PBS -N salmon
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
READS_FOLDER="/home/ref-bioinfo/ifremer/phytox/p-parvum-mixotrophie/data/raw-sequence/"
REF_FASTA="/home1/scratch/ltrouill/rnabloom_20250402_082249/rnabloom.transcripts.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/salmon/"
RESULT_FOLDER="/home1/scratch/ltrouill/salmon_$(date +%Y%m%d_%H%M%S)"
LOGFILE="${LOG_FOLDER}/salmon_$(date +%Y%m%d_%H%M%S).log"

# Créer les dossiers si nécessaire
mkdir -p "$LOG_FOLDER"
mkdir -p "$RESULT_FOLDER"



echo "Chargement de Salmon..." >>"$LOGFILE"
. /appli/bioinfo/salmon/1.10.0/env.sh

LEFT_READS=$(find "$READS_FOLDER" -name "*_R1.fastq.gz" | sort | tr '\n' ' ')
RIGHT_READS=$(find "$READS_FOLDER" -name "*_R2.fastq.gz" | sort | tr '\n' ' ')

# Index the reference genome
echo "--- Construction de l'index Salmon ---" >>"$LOGFILE"
INDEX="${RESULT_FOLDER}/Salmon_index"
salmon index -t "$REF_FASTA" -i "$INDEX" >>"$LOGFILE" 2>&1
echo "Construction terminée" >>"$LOGFILE"


echo "--- Exécution de Salmon ---" >>"$LOGFILE"
salmon quant -i $INDEX -l A -1 $LEFT_READS -2 $RIGHT_READS --validateMappings -o "$RESULT_FOLDER" >>"$LOGFILE" 2>&1
echo "Exécution terminée" >>"$LOGFILE"