#!/bin/bash
#PBS -N Trim
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
FASTQ_FILE="/home/datawork-lpba/Prymnesium/PrymneTranscripto/RNA-longReads-fev25/Galaxy43-[Prymnesium_cDNA Porechop OK Qualite Ok].fastq"
SCRIPT="/home1/datawork/ltrouill/ifremer/SCRIPTS/FilterNTrim/fastq_trim.py"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/autres/"
RESULT_FOLDER="/home1/datawork/ltrouill/ifremer/data/Trim_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_FOLDER/trim_$(date +%Y%m%d_%H%M%S).log"

# Créer les dossiers nécessaires
mkdir -p "$RESULT_FOLDER" 
mkdir -p "$LOG_FOLDER" 

# Activer l'environnement conda
source /appli/anaconda/versions/miniforge3-24.11.3-0/etc/profile.d/conda.sh
conda activate bioinfo_env 

# Exécuter le script Python
cd "$RESULT_FOLDER" 
python3 "$SCRIPT" "$FASTQ_FILE" \
    "$RESULT_FOLDER/Prymne_mrna.fastq" \
    "$RESULT_FOLDER/Prymne_dna.fastq" \
    "$RESULT_FOLDER/Prymne_ncrna.fastq" \
    "$RESULT_FOLDER/Prymne_arn.fastq" \
    "$RESULT_FOLDER/report.txt" &>> "$LOG_FILE"

# Vérifier si le script Python a réussi
if [ $? -ne 0 ]; then
    echo "Erreur : Le script Python a échoué. Consultez le fichier log : $LOG_FILE"
    conda deactivate
    exit 1
fi

# Désactiver l'environnement conda
conda deactivate || { echo "Erreur : Impossible de désactiver l'environnement conda"; exit 1; }

echo "Traitement terminé avec succès. Les résultats sont dans $RESULT_FOLDER"