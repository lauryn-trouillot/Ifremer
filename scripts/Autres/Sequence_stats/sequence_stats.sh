#!/bin/bash
#PBS -N Stats
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=02:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/Others_error/"
RESULT_FILE="sequence_stats.txt"
SCRIPT_PATH="/home1/datawork/ltrouill/ifremer/scripts/Autres/Sequence_stats/main.sh"

mkdir -p "$LOG_FOLDER"

declare -a FILES=(
    "/home1/datawork/ltrouill/ifremer/results/minion/rnabloom_Karlodinium_20250131_2/rnabloom.transcripts.fasta"
    "/home1/datawork/ltrouill/ifremer/results/minion/rnabloom_Karlodinium_20250131_1/rnabloom.transcripts.fasta"
    "/home1/datawork/ltrouill/ifremer/results/illumina_minion/rnaSPADES/Karlodinium_rnaspade_20250110_155148/transcripts.fasta"
    "/home1/datawork/ltrouill/ifremer/results/illumina/Trinity_20250106/Karlodinium_trinity_20250106_143432.Trinity.fasta"
    "/home1/datawork/ltrouill/ifremer/results/illumina/Trinity_20241128/Karlodinium_trinity_20241128_225603.Trinity.fasta"
    "/home1/datawork/ltrouill/ifremer/data/rawdata/illumina/Karlodinium_bib.fasta"
    
)

for FILE in "${FILES[@]}"; 
do
    BASENAME=$(basename "$FILE")
    echo "Running sequence stats for $BASENAME" 2>> "${LOG_FOLDER}/stats_errors.log"
    echo "Statistiques du fichier $BASENAME : " >> "$RESULT_FILE"
    if $SCRIPT_PATH "$FILE" >> "$RESULT_FILE"; then
        echo "Ajouté au fichier txt" 2>> "${LOG_FOLDER}/stats_errors.log"
    else
        echo "Erreur lors de l'exécution de $BASENAME" 2>> "${LOG_FOLDER}/stats_errors.log"
    fi
done