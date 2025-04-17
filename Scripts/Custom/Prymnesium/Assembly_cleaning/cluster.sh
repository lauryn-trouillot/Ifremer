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
ASSEMBLY_FILE="/home1/scratch/ltrouill/rnaspades_20250328_184112/Primne_1line.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/Clustering/"
LOG_FILE="$LOG_FOLDER/cluster_${TIMESTAMP}.log"
RESULT_FOLDER="/home1/scratch/ltrouill/cluster_${TIMESTAMP}"
CLUSTER_FOLDER="$RESULT_FOLDER/CLUSTERS"
BUSCOS_FOLDER="$RESULT_FOLDER/BUSCOS"
DB_FOLDER="/home1/datawork/ltrouill/ifremer/data/busco_downloads/lineages/eukaryota_odb10"
CSV_FILE="$RESULT_FOLDER/cluster_result.csv"

# Paramètres initiaux
BUSCO_VALUE=200
SIMILARITY_VALUE=1

# Vérification de l'existence d'un dossier cluster_20*
EXISTING_CLUSTER=$(ls -d /home1/scratch/ltrouill/cluster_20* 2>/dev/null | tail -n 1)
if [ -n "$EXISTING_CLUSTER" ]; then
    echo "[INFO] Reprise à partir du dossier existant : $EXISTING_CLUSTER" | tee -a "$LOG_FILE"
    RESULT_FOLDER="$EXISTING_CLUSTER"
    CLUSTER_FOLDER="$RESULT_FOLDER/CLUSTERS"
    BUSCOS_FOLDER="$RESULT_FOLDER/BUSCOS"
    CSV_FILE="$RESULT_FOLDER/cluster_result.csv"
else
    # Création des répertoires
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

# Début du pipeline
echo "[INFO] Début de la pipeline - $TIMESTAMP" | tee -a "$LOG_FILE"

while (( $(echo "$BUSCO_VALUE >= 70" | bc -l) )); do
    echo "[DEBUG] Valeur actuelle de BUSCO_VALUE: $BUSCO_VALUE" | tee -a "$LOG_FILE"
    echo "[DEBUG] Valeur actuelle de SIMILARITY_VALUE: $SIMILARITY_VALUE" | tee -a "$LOG_FILE"

    THRESHOLD_VALUE=$(SET_THRESHOLD "$SIMILARITY_VALUE")
    CLUSTER_FILE="$CLUSTER_FOLDER/cluster_${SIMILARITY_VALUE}_${THRESHOLD_VALUE}.fasta"

    if [ -f "$CLUSTER_FILE" ]; then
        echo "[INFO] Cluster file $CLUSTER_FILE already exists, skipping clustering" | tee -a "$LOG_FILE"
    else
        echo "[INFO] Clustering avec seuil $THRESHOLD_VALUE et similarité $SIMILARITY_VALUE" | tee -a "$LOG_FILE"
        . /appli/bioinfo/cd-hit/4.8.1/env.sh
        cd-hit-est -i "$ASSEMBLY_FILE" -o "$CLUSTER_FILE" -c "$SIMILARITY_VALUE" -n "$THRESHOLD_VALUE" -M 300000 -T 15 &
        wait
    fi

    BUSCO_FOLDER="$BUSCOS_FOLDER/BUSCO_$(basename "$CLUSTER_FILE")"
    if [ -d "$BUSCO_FOLDER" ]; then
        echo "[INFO] BUSCO analysis already done for $CLUSTER_FILE, skipping BUSCO" | tee -a "$LOG_FILE"
        BUSCO_VALUE=$(grep "C:" "$BUSCO_FOLDER/short_summary.specific.eukaryota_odb10.BUSCO_$(basename "$CLUSTER_FILE").txt" | awk -F'[:,%]' '{print $2}' )
    else
        echo "[INFO] BUSCO analysis pour $CLUSTER_FILE" | tee -a "$LOG_FILE"
        . /appli/bioinfo/busco/5.6.1/env.sh
        cd $BUSCOS_FOLDER
        busco -i "$CLUSTER_FILE"  -m transcriptome --offline -f -c 15 -l "$DB_FOLDER" &>> "$LOG_FILE" &
        wait
        BUSCO_VALUE=$(grep "C:" "$BUSCO_FOLDER/short_summary.specific.eukaryota_odb10.BUSCO_$(basename "$CLUSTER_FILE").txt" | awk -F'[:,%]' '{print $2}' )
    fi

    NB_READS=$(grep -c '^>' "$CLUSTER_FILE")
    echo "$NB_READS,$THRESHOLD_VALUE,$SIMILARITY_VALUE,$BUSCO_VALUE" >> "$CSV_FILE"
    
    SIMILARITY_VALUE=$(echo "$SIMILARITY_VALUE - 0.05" | bc)
    echo "[DEBUG] Nouvelle valeur de SIMILARITY_VALUE après décrémentation: $SIMILARITY_VALUE" | tee -a "$LOG_FILE"
done

echo "[INFO] Génération des résultats graphiques" | tee -a "$LOG_FILE"

source /appli/anaconda/versions/4.8.3/etc/profile.d/conda.sh 
cd /home1/datawork/ltrouill
conda activate bioinfo_env
python3 "$CHEMIN/scripts/Autres/cluster_figure.py" "$CSV_FILE" &>> "$LOG_FILE"
conda deactivate

echo "[INFO] Fin de la pipeline - $TIMESTAMP" | tee -a "$LOG_FILE"
