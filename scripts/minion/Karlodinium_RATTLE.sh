#!/bin/bash 
#PBS -N RATTLE_assembly
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=50:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"
. /appli/bioinfo/rattle/1.0.0/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_RATTLE"
CHEMIN="/home/datawork-lpba/karlodinium/Transcriptome/RawDataTEMP/Karlodinium_RNAref-2/karlodinium_RNAref-2/20240930_1630_MN20979_ASI088_0cdfc4f6/fastq_pass/"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/RATTLE_errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/result_RATTLE"
CLUSTERS_FOLDER="$RESULT_FOLDER/clusters"
EX_CLUSTERS_FOLDER="$RESULT_FOLDER/Extract_clusters"
CORRECTED_FOLDER="$RESULT_FOLDER/corrected"
ARCHIVE_NAME="${RESULT_FOLDER}.tar.gz"
LOG_FILE="$LOG_FOLDER/${TIMESTAMP}_${NAME}_pipeline.log"
RUN_STEP_2=true  # Modifiez à `false` pour sauter l'étape 2

# Création des dossiers nécessaires
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$CLUSTERS_FOLDER" "$EX_CLUSTERS_FOLDER" "$CORRECTED_FOLDER"

# Initialisation du fichier log
echo "=== Début du pipeline RATTLE - $TIMESTAMP ===" > "$LOG_FILE"

# Validation des données d'entrée
if [ -z "$(ls -A "$CHEMIN"/*.fastq.gz 2>/dev/null)" ]; then
    echo "Erreur : Aucun fichier FASTQ trouvé dans $CHEMIN." >> "$LOG_FILE"
    exit 1
fi

# Combinaison des fichiers FASTQ
echo "Combinaison des fichiers FASTQ en un seul fichier..." >> "$LOG_FILE"
gunzip -c "$CHEMIN"/*.fastq.gz > "$RESULT_FOLDER/combined_reads.fastq"
if [ $? -ne 0 ] || [ ! -s "$RESULT_FOLDER/combined_reads.fastq" ]; then
    echo "Erreur : Échec lors de la combinaison des fichiers FASTQ." >> "$LOG_FILE"
    exit 1
fi

# Étape 1 : Clustering des reads
CLUSTERED_TRANSCRIPTS="$CLUSTERS_FOLDER/clusters.out"
if [ -f "$CLUSTERED_TRANSCRIPTS" ]; then
    echo "Étape 1 ignorée : Fichier $CLUSTERED_TRANSCRIPTS déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Étape 1 : Clustering des reads ---" >> "$LOG_FILE"
    rattle cluster \
        -i "$RESULT_FOLDER/combined_reads.fastq" \
        --iso \
        -t 15 \
        -o "$CLUSTERS_FOLDER" \
        >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$CLUSTERED_TRANSCRIPTS" ]; then
        echo "Erreur : Clustering échoué." >> "$LOG_FILE"
        exit 1
    fi
fi

# Étape 2 : Extraction des fichiers FASTQ par cluster (optionnelle)
if $RUN_STEP_2; then
    if ls "$EX_CLUSTERS_FOLDER"/*.fq 1> /dev/null 2>&1; then
        echo "Étape 2 ignorée : Fichiers .fq déjà présents dans $EX_CLUSTERS_FOLDER." >> "$LOG_FILE"
    else
        echo -e "\n--- Étape 2 : Extraction des fichiers FASTQ par cluster ---" >> "$LOG_FILE"
        rattle extract_clusters \
            -i "$RESULT_FOLDER/combined_reads.fastq" \
            -c "$CLUSTERED_TRANSCRIPTS" \
            -o "$EX_CLUSTERS_FOLDER" \
            --fastq \
            >> "$LOG_FILE" 2>&1

        # Vérification du succès
        if [ $? -ne 0 ] || ! ls "$EX_CLUSTERS_FOLDER"/*.fq 1> /dev/null 2>&1; then
            echo "Erreur : Extraction échouée" >> "$LOG_FILE"
            exit 1
        fi
    fi
else
    echo "Étape 2 sautée (RUN_STEP_2=false)." >> "$LOG_FILE"
fi

# Étape 3 : Correction des reads
CORRECTED_READS="$CORRECTED_FOLDER/corrected.fq"

if [ -f "$CORRECTED_READS" ]; then
    echo "Étape 3 ignorée : Fichier $CORRECTED_READS déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Étape 3 : Correction des reads ---" >> "$LOG_FILE"

    # Validation des fichiers d'entrée
    if [ ! -f "$RESULT_FOLDER/combined_reads.fastq" ] || [ ! -s "$RESULT_FOLDER/combined_reads.fastq" ]; then
        echo "Erreur : Le fichier combined_reads.fastq est manquant ou vide." >> "$LOG_FILE"
        exit 1
    fi

    if [ ! -f "$CLUSTERED_TRANSCRIPTS" ] || [ ! -s "$CLUSTERED_TRANSCRIPTS" ]; then
        echo "Erreur : Le fichier $CLUSTERED_TRANSCRIPTS est manquant ou vide." >> "$LOG_FILE"
        exit 1
    fi

    # Exécution de rattle correct
    rattle correct \
        -i "$RESULT_FOLDER/combined_reads.fastq" \
        -c "$CLUSTERED_TRANSCRIPTS" \
        -t 15 \
        -o "$CORRECTED_FOLDER" \
        >> "$LOG_FILE" 2>&1

    # Vérification de l'exécution
    if [ $? -ne 0 ] || [ ! -f "$CORRECTED_READS" ]; then
        echo "Erreur : Correction échouée." >> "$LOG_FILE"
        exit 1
    fi
fi

# Étape 4 : Polissage des séquences consensus
CONSENSI_FILE="$CORRECTED_FOLDER/consensi.fq"

if [ -f "$POLISHED_READS" ]; then
    echo "Étape 4 ignorée : Fichier $POLISHED_READS déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Étape 4 : Polissage des séquences consensus ---" >> "$LOG_FILE"
    
    # Vérification de la disponibilité du fichier consensi.fq
    if [ ! -f "$CONSENSI_FILE" ] || [ ! -s "$CONSENSI_FILE" ]; then
        echo "Erreur : Le fichier $CONSENSI_FILE est manquant ou vide." >> "$LOG_FILE"
        exit 1
    fi

    # Lancement de l'étape de polissage
    rattle polish \
    -i "$CONSENSI_FILE"\
    -t 15 \
    -o "$RESULT_FOLDER" \
    >> "$LOG_FILE" 2>&1

    # Vérification du succès
    if [ $? -ne 0 ] || [ ! -f "$RESULT_FOLDER/transcriptome.fq" ]; then
        echo "Erreur : Polissage échoué." >> "$LOG_FILE"
        exit 1
    fi
fi

. /appli/bioinfo/rattle/1.0.0/delenv.sh

# Compression des résultats
if [ -f "$ARCHIVE_NAME" ]; then
    echo "Compression ignorée : Fichier $ARCHIVE_NAME déjà existant." >> "$LOG_FILE"
else
    echo -e "\n--- Compression des résultats ---" >> "$LOG_FILE"
    tar -czvf "$ARCHIVE_NAME" -C "$RESULT_FOLDER" . >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "Erreur : Compression des résultats échouée." >> "$LOG_FILE"
        exit 1
    fi
fi

# Copie des résultats compressés
echo -e "\n--- Copie des résultats compressés ---" >> "$LOG_FILE"
cp "$ARCHIVE_NAME" "/home1/datawork/ltrouill/ifremer/results/minion/" >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "Erreur : Copie des résultats échouée." >> "$LOG_FILE"
    exit 1
fi

# Fin du pipeline
echo -e "\n=== Fin du pipeline RATTLE ===" >> "$LOG_FILE"
exit 0
