#!/bin/bash 
#PBS -N RATTLE_assembly
#PBS -q omp
#PBS -l ncpus=24
#PBS -l mem=100gb
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
THREADS=15        # Nombre de threads
RUN_STEP_2=false  # Passez à `true` pour activer l'étape 2
VERBOSE="--verbose"

# Chemins (à adapter)
FILENAME="/path/to/Long_reads.fastq.gz"
LOG_FOLDER="/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder_${TIMESTAMP}"
CLUSTERS_FOLDER="$RESULT_FOLDER/clusters"
EX_CLUSTERS_FOLDER="$RESULT_FOLDER/Extract_clusters"
CORRECTED_FOLDER="$RESULT_FOLDER/corrected"
LOG_FILE="$LOG_FOLDER/${TIMESTAMP}_${NAME}.log"

# Création des dossiers
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$CLUSTERS_FOLDER" "$EX_CLUSTERS_FOLDER" "$CORRECTED_FOLDER"

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
    rattle cluster -i "$FILENAME" -t "$THREADS" -VERBOSE -o "$CLUSTERS_FOLDER" >> "$LOG_FILE" 2>&1
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

####################################
# Étape 3 : Correction des lectures
####################################
CORRECTED_READS="$CORRECTED_FOLDER/corrected.fq"
if [ -f "$CORRECTED_READS" ]; then
    echo "Étape 3 ignorée : $CORRECTED_READS déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Étape 3 : Correction des reads ---" >> "$LOG_FILE"
    
    if [ ! -f "$FILENAME" ]; then
        echo "Erreur : $FILENAME manquant." >> "$LOG_FILE"
        exit 1
    fi
    if [ ! -f "$CLUSTERED_TRANSCRIPTS" ]; then
        echo "Erreur : $CLUSTERED_TRANSCRIPTS manquant." >> "$LOG_FILE"
        exit 1
    fi

    rattle correct -i "$FILENAME" -c "$CLUSTERED_TRANSCRIPTS" -t "$THREADS" $VERBOSE -o "$CORRECTED_FOLDER" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$CORRECTED_READS" ]; then
        echo "Erreur : Correction échouée." >> "$LOG_FILE"
        exit 1
    fi
fi

######################################
# Étape 4 : Polissage des séquences
######################################
CONSENSI_FILE="$CORRECTED_FOLDER/consensi.fq"
POLISHED_READS="$RESULT_FOLDER/transcriptome.fq"

if [ -f "$POLISHED_READS" ]; then
    echo "Étape 4 ignorée : $POLISHED_READS déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Étape 4 : Polissage ---" >> "$LOG_FILE"
    if [ ! -f "$CONSENSI_FILE" ]; then
        echo "Erreur : $CONSENSI_FILE manquant." >> "$LOG_FILE"
        exit 1
    fi

    rattle polish -i "$CONSENSI_FILE" -t "$THREADS" $VERBOSE -o "$RESULT_FOLDER" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$POLISHED_READS" ]; then
        echo "Erreur : Polissage échoué." >> "$LOG_FILE"
        exit 1
    fi
fi

# Désactivation de l'environnement
. /appli/bioinfo/rattle/1.0.0/delenv.sh

echo -e "\n=== Fin du pipeline RATTLE ===" >> "$LOG_FILE"
exit 0