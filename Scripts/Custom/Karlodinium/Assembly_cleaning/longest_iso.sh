#!/bin/bash
#PBS -N isoforms
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
ASSEMBLY_FILE="/home1/datawork/ltrouill/ifremer/Prymnesium/Results/rnaspades/rnaspades_20250407_093832/transcripts.fasta"
SCRIPT="/home1/datawork/ltrouill/ifremer/Prymnesium/Scripts/Prymnesium_pipeline/Assembly_cleaning/longest_iso.py"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/autres/"
RESULT_FOLDER="/home1/scratch/ltrouill/isoforms_$(date +%Y%m%d_%H%M%S)"

# Créer les dossiers nécessaires
mkdir -p "$RESULT_FOLDER" 
mkdir -p "$LOG_FOLDER" 

# Activer l'environnement conda
source /appli/anaconda/versions/miniforge3-24.11.3-0/etc/profile.d/conda.sh
conda activate bioinfo_env 

python3 "$SCRIPT" "$ASSEMBLY_FILE" "$RESULT_FOLDER/longest_isoforms.fasta" "$RESULT_FOLDER/rapport_longest_isoforms.txt"