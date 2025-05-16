#!/bin/bash 
#PBS -N RATTLE_assembly
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

#######################
# Chargement du module
#######################
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/rattle/1.0.0/env.sh

#######################
# Variables globales
#######################
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="RATTLE_pipeline_${TIMESTAMP}"

# Paramètres RATTLE
THREADS=15      # Nombre de threads
RUN_STEP_2=true  # Passez à `true` pour activer l'étape 2
VERBOSE="--verbose"

# Chemins (à adapter)
FILENAME="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Karlodinium/Long_reads/porechop_20250416/Karlodinium_cDNA_cleaned.fastq"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/RATTLE"
RESULT_FOLDER="/home1/scratch/ltrouill/RATTLE_${TIMESTAMP}"
CLUSTERS_FOLDER="$RESULT_FOLDER/clusters"
EX_CLUSTERS_FOLDER="$RESULT_FOLDER/Extract_clusters"
LOG_FILE="$LOG_FOLDER/${TIMESTAMP}_${NAME}.log"

# Création des dossiers
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$CLUSTERS_FOLDER" "$EX_CLUSTERS_FOLDER"
# Initialisation du fichier log
echo "=== Début du pipeline RATTLE ===" > "$LOG_FILE"

#######################
# Étape 1 : Clustering
#######################
CLUSTERED_TRANSCRIPTS="$CLUSTERS_FOLDER/clusters.out"
if [ -f "$CLUSTERED_TRANSCRIPTS" ]; then
    echo "Étape 1 ignorée : $CLUSTERED_TRANSCRIPTS déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Étape 1 : Clustering des reads ---" >> "$LOG_FILE"
    rattle cluster -i "$FILENAME" -t "$THREADS" $VERBOSE -o "$CLUSTERS_FOLDER" -k 16 --iso --iso-kmer-size 16 --iso-score-threshold 0.5 --iso-max-variance 20 >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$CLUSTERED_TRANSCRIPTS" ]; then
        echo "Erreur : Clustering échoué." >> "$LOG_FILE"
        exit 1
    fi
fi

##########################
# Étape 2 : Extraction fq
##########################
if $RUN_STEP_2; then
    if ls "$EX_CLUSTERS_FOLDER"/*.fq 1> /dev/null 2>&1; then
        echo "Étape 2 ignorée : .fq déjà présents." >> "$LOG_FILE"
    else
        echo -e "\n--- Étape 2 : Extraction des .fq ---" >> "$LOG_FILE"
        rattle extract_clusters -i "$FILENAME" -c "$CLUSTERED_TRANSCRIPTS" -o "$EX_CLUSTERS_FOLDER" $VERBOSE --fastq >> "$LOG_FILE" 2>&1
        
        if [ $? -ne 0 ] || ! ls "$EX_CLUSTERS_FOLDER"/*.fq 1> /dev/null 2>&1; then
            echo "Erreur : Extraction échouée." >> "$LOG_FILE"
            exit 1
        fi
    fi
else
    echo "Étape 2 sautée (RUN_STEP_2=false)." >> "$LOG_FILE"
fi
