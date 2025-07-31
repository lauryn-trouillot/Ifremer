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
SEQ_FILE="Chemin/vers/le/dossier/transcriptome.fasta"  # Chemin vers le fichier FASTA ou FASTQ
LOG_FOLDER="Chemin/vers/le/dossier/logs/BUSCO"
RESULT_FOLDER="Chemin/vers/le/dossier/Results/BUSCO/${NAME}"
DB_FOLDER="Chemin/vers/la/db/eukaryota_odb10" # A télécharger
FASTQ=False  # Mettre à true si le fichier d'entrée est au format FASTQ
LOGFILE="${LOG_FOLDER}/busco_${TIMESTAMP}.log"

# Création des dossiers
mkdir -p "$RESULT_FOLDER" "$LOG_FOLDER"

# Conversion FASTQ → FASTA si nécessaire
if [[ "$FASTQ" == "True" ]]; then
    echo "Conversion de ${SEQ_FILE} en FASTA..." >>"$LOGFILE"
    . /appli/bioinfo/seqtk/1.4/env.sh
    seqtk seq -a "${SEQ_FILE}" > "${RESULT_FOLDER}/transcriptome.fasta" 2>>"$LOGFILE"
    if [[ $? -ne 0 ]]; then
        echo "Erreur : la conversion du fichier FASTQ en FASTA a échoué." >>"$LOGFILE"
        exit 1
    fi
    SEQ_FILE="${RESULT_FOLDER}/transcriptome.fasta"  # Met à jour le fichier d'entrée pour BUSCO
fi

# Chargement de l'environnement BUSCO
. /appli/bioinfo/busco/5.6.1/env.sh

# Commande BUSCO
echo "Démarrage de BUSCO..." >>"$LOGFILE"
cd "$RESULT_FOLDER"
busco -i "${SEQ_FILE}" -m transcriptome --offline -f -c 15 \
      -l "${DB_FOLDER}" >>"$LOGFILE" 2>&1

if [[ $? -ne 0 ]]; then
    echo "Erreur : l'exécution de BUSCO a échoué." >>"$LOGFILE"
    exit 1
fi

echo "Analyse BUSCO terminée !" >>"$LOGFILE"
