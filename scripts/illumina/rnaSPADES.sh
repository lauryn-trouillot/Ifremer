#!/bin/bash 
#PBS -N rnaSPADES
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}" 
. /appli/bioinfo/spades/4.0.0/env.sh

# Initialisation des variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_rnaspades_${TIMESTAMP}"
CHEMIN="/home1/datawork/ltrouill/ifremer/"
LOG_FOLDER="${CHEMIN}/errors/rnaspades_errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/Karlodinium_rnaspade_${TIMESTAMP}"
minION_FILE="${CHEMIN}/data/rawdata/minion/Karlodinium_cDNA.fastq"
READS_FOLDER="${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/"

# Vérifier l'existence des fichiers nécessaires
if [ ! -f "$minION_FILE" ]; then
    echo "Erreur : le fichier MinION '$minION_FILE' est introuvable."
    exit 1
fi

# Création des répertoires si nécessaire
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"


# Exclure certains fichiers de lecture Illumina
EXCLUDE="2|5|8|13|14|18" # Ajouter les indices des échantillons à exclure

# Combiner les fichiers de lecture Illumina en excluant certains échantillons
for file in "$READS_FOLDER"/*_R1.fastq.gz; do
    if [[ ! "$file" =~ _($EXCLUDE)_ ]]; then
        cat "$file" >> "$RESULT_FOLDER/LEFT.fastq.gz"
    fi
done

for file in "$READS_FOLDER"/*_R2.fastq.gz; do
    if [[ ! "$file" =~ _($EXCLUDE)_ ]]; then
        cat "$file" >> "$RESULT_FOLDER/RIGHT.fastq.gz"
    fi
done

# Définir les variables de lecture
LEFT_READS="$RESULT_FOLDER/LEFT.fastq.gz"
RIGHT_READS="$RESULT_FOLDER/RIGHT.fastq.gz"

# Vérification si des fichiers de lecture ont été trouvés
if [ -z "$LEFT_READS" ] || [ -z "$RIGHT_READS" ]; then
    echo "Erreur : Aucune lecture Illumina trouvée après exclusion des échantillons."
    exit 1
fi

# Exécution de SPAdes avec les fichiers de lecture Illumina et MinION
echo "Début de l'assemblage avec SPAdes..." | tee -a "${LOG_FOLDER}/spades_${TIMESTAMP}.log"

spades.py -1 "$LEFT_READS" -2 "$RIGHT_READS" \
        --nanopore "$minION_FILE" \
        -o "$RESULT_FOLDER" \
        --rna \
        2>&1 | tee -a "${LOG_FOLDER}/spades_${TIMESTAMP}.log"

# Vérification si SPAdes a réussi
if [ $? -ne 0 ]; then
    echo "Erreur : SPAdes a échoué. Vérifiez les logs pour plus d'informations." | tee -a "${LOG_FOLDER}/spades_${TIMESTAMP}.log"
    exit 1
fi

echo "L'assemblage SPAdes est terminé avec succès." | tee -a "${LOG_FOLDER}/spades_${TIMESTAMP}.log"
