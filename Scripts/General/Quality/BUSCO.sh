#!/bin/bash
#PBS -N busco
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=30gb
#PBS -l walltime=05:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="BUSCO_${TIMESTAMP}"
SEQ_FILE="/path/to/assembly_file"
LOG_FOLDER="$/path/to/log_folder"
RESULT_FOLDER="/path/to/result_folder"
DB_FOLDER="/home1/datawork/ltrouill/ifremer/DATA/busco_downloads/lineages/eukaryota_odb10" # A télécharger
FASTQ=False  # Mettre à true si le fichier d'entrée est au format FASTQ

# Création des dossiers
mkdir -p "$RESULT_FOLDER" "$LOG_FOLDER"

# Conversion FASTQ → FASTA si nécessaire
if $FASTQ; then
    echo "Conversion de ${SEQ_FILE} en FASTA..."
    . /appli/bioinfo/seqtk/1.4/env.sh
    seqtk seq -a "${SEQ_FILE}" > "${RESULT_FOLDER}/transcriptome.fasta" 
    if [[ $? -ne 0 ]]; then
        echo "Erreur : la conversion du fichier FASTQ en FASTA a échoué." >&2
        exit 1
    fi
    SEQ_FILE="${RESULT_FOLDER}/transcriptome.fasta"  # Met à jour le fichier d'entrée pour BUSCO
fi

# Chargement de l'environnement BUSCO
. /appli/bioinfo/busco/5.6.1/env.sh

# Commande BUSCO
echo "Démarrage de BUSCO..."
cd $RESULT_FOLDER
busco -i "${SEQ_FILE}" -m transcriptome --offline -f -c 15 \
      -l "${DB_FOLDER}" \
      2>&1 | tee "${LOG_FOLDER}/${NAME}.log"

if [[ $? -ne 0 ]]; then
    echo "Erreur : l'exécution de BUSCO a échoué." >&2
    exit 1
fi

echo "Analyse BUSCO terminée !"
