#!/bin/bash
#PBS -N cluster
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="cluster_${TIMESTAMP}"

CHEMIN="/home1/datawork/ltrouill/Ifremer"
ASSEMBLY_FILE="/home1/scratch/ltrouill/transcripts_analysis_20250430_064812/filtered_transcripts.fasta"
LOG_FOLDER="$CHEMIN/Errors/clustering"
LOG_FILE="$LOG_FOLDER/${NAME}.log"
RESULT_FOLDER="/home1/scratch/ltrouill/${NAME}"
CLUSTER_FOLDER="$RESULT_FOLDER/CLUSTERS"
BUSCOS_FOLDER="$RESULT_FOLDER/BUSCOS"
DB_FOLDER="$CHEMIN/Data/busco_downloads/lineages/eukaryota_odb10"
CSV_FILE="$RESULT_FOLDER/cluster_result.csv"

# Paramètres initiaux
SIMILARITY_VALUES=(0.99 0.98 0.97 0.96 0.95)

# Vérification de l'existence d'un dossier cluster_20*
EXISTING_CLUSTER=$(ls -d /home1/scratch/ltrouill/cluster_20* 2>/dev/null | tail -n 1)
if [ -n "$EXISTING_CLUSTER" ]; then
    echo "[INFO] Reprise à partir du dossier existant : $EXISTING_CLUSTER" >> "$LOG_FILE"
    RESULT_FOLDER="$EXISTING_CLUSTER"
    CLUSTER_FOLDER="$RESULT_FOLDER/CLUSTERS"
    BUSCOS_FOLDER="$RESULT_FOLDER/BUSCOS"
    CSV_FILE="$RESULT_FOLDER/cluster_result.csv"
else
    mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER" "$CLUSTER_FOLDER" "$BUSCOS_FOLDER"
fi

# Fonction pour définir le seuil
SET_THRESHOLD() {
    local SIMILARITY_VAL=$1
    if (( $(echo "$SIMILARITY_VAL >= 0.95" | bc -l) )); then echo 10
    elif (( $(echo "$SIMILARITY_VAL >= 0.90" | bc -l) )); then echo 9
    elif (( $(echo "$SIMILARITY_VAL >= 0.88" | bc -l) )); then echo 7
    elif (( $(echo "$SIMILARITY_VAL >= 0.86" | bc -l) )); then echo 6
    elif (( $(echo "$SIMILARITY_VAL >= 0.80" | bc -l) )); then echo 5
    elif (( $(echo "$SIMILARITY_VAL >= 0.75" | bc -l) )); then echo 4
    else echo "Erreur : Similarité trop basse" && exit 1
    fi
}

echo "[INFO] Début de la pipeline - $TIMESTAMP" >> "$LOG_FILE"

PREVIOUS_FILE="$ASSEMBLY_FILE"

for SIMILARITY_VALUE in "${SIMILARITY_VALUES[@]}"; do
    echo "[DEBUG] SIMILARITY_VALUE: $SIMILARITY_VALUE" >> "$LOG_FILE"

    THRESHOLD_VALUE=$(SET_THRESHOLD "$SIMILARITY_VALUE")
    CLUSTER_FILE="$CLUSTER_FOLDER/cluster_${SIMILARITY_VALUE}_${THRESHOLD_VALUE}.fasta"
    INPUT_FILE="$PREVIOUS_FILE"

    if [ ! -f "$INPUT_FILE" ]; then
        echo "[ERREUR] Fichier introuvable : $INPUT_FILE" | tee -a "$LOG_FILE"
        exit 1
    fi

    . /appli/bioinfo/cd-hit/4.8.1/env.sh
    cd-hit-est -i "$INPUT_FILE" -o "$CLUSTER_FILE" -c "$SIMILARITY_VALUE" -n "$THRESHOLD_VALUE" -M 300000 -T 15

    CLUSTER_BASENAME=$(basename "$CLUSTER_FILE" .fasta)
    BUSCO_FOLDER="$BUSCOS_FOLDER/BUSCO_${CLUSTER_BASENAME}"

    if [ -d "$BUSCO_FOLDER" ]; then
        echo "[INFO] BUSCO already done for $CLUSTER_FILE" >> "$LOG_FILE"
        BUSCO_VALUE=$(grep "C:" "$BUSCO_FOLDER/short_summary.specific.eukaryota_odb10.BUSCO_${CLUSTER_BASENAME}.txt" | awk -F'[:,%]' '{print $2}')
    else
        echo "[INFO] BUSCO analysis for $CLUSTER_FILE" >> "$LOG_FILE"
        . /appli/bioinfo/busco/5.6.1/env.sh
        cd "$BUSCOS_FOLDER"
        busco -i "$CLUSTER_FILE" -m transcriptome --offline -f -c 15 -l "$DB_FOLDER" >> "$LOG_FILE"
        BUSCO_VALUE=$(grep "C:" "$BUSCO_FOLDER/short_summary.specific.eukaryota_odb10.BUSCO_${CLUSTER_BASENAME}.txt" | awk -F'[:,%]' '{print $2}')
    fi

    NB_READS=$(grep -c '^>' "$CLUSTER_FILE")
    echo "$NB_READS,$THRESHOLD_VALUE,$SIMILARITY_VALUE,$BUSCO_VALUE" >> "$CSV_FILE"

    PREVIOUS_FILE="$CLUSTER_FILE"
done

echo "[INFO] Génération des résultats graphiques" >> "$LOG_FILE"

source /appli/anaconda/versions/miniforge3-24.11.3-0/etc/profile.d/conda.sh
cd /home1/datawork/ltrouill
conda activate bioinfo_env
python3 "$CHEMIN/Scripts/Prymnesium/cluster_figure.py" "$CSV_FILE" >> "$LOG_FILE"
conda deactivate

echo "[INFO] Fin de la pipeline - $TIMESTAMP" >> "$LOG_FILE"
