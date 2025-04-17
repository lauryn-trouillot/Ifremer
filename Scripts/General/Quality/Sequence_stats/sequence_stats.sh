#!/bin/bash
#PBS -N Stats
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=02:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/autres"
RESULT_FILE="sequence_stats.txt"
SCRIPT_PATH="main.sh"

mkdir -p "$LOG_FOLDER"

declare -a FILES=(
    "/home1/datawork/ltrouill/ifremer/Prymnesium/Results/Trinity/trinity_20250407_160011/trinity_20250407_160011.Trinity.fasta" 
    "/home1/datawork/ltrouill/ifremer/Prymnesium/Results/rnaspades/rnaspades_20250407_093832/transcripts.fasta"
    "/home/datawork-lpba/Prymnesium/PrymneTranscripto/AssemblageGreg/ClusterRattelCustomGreg-Primnesium.fasta"
    "/home1/scratch/ltrouill/isoforms_20250408_074313/longest_isoforms.fasta"
    "/home1/scratch/ltrouill/cluster_20250408_095429/cluster_0.95_10.fasta"
)

echo "---- Les tatistiques d'assemblage : ---- " > "$RESULT_FILE"

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