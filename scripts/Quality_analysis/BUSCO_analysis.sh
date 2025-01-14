#!/bin/bash
#PBS -N busco
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=48:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ASSEMBLY="Trinity"
NAME="BUSCO_${ASSEMBLY}_${TIMESTAMP}"
CHEMIN="/home1/datawork/ltrouill/ifremer/"
ARCHIVE="${CHEMIN}results/illumina/result_Trinity.tar.gz"
SEQ_FILE="${CHEMIN}results/illumina/Trinity_20250108/Karlodinium_trinity_20250106_143432.Trinity.fasta"
LOG_FOLDER="${CHEMIN}errors/BUSCO_errors/"
RESULT_FOLDER="${CHEMIN}results/BUSCO/${NAME}"  # Répertoire de résultats
DB_FOLDER="${CHEMIN}data/busco_downloads/lineages/eukaryota_odb10"
FASTQ=False  # Mettre à true si le fichier d'entrée est au format FASTQ

# Création des dossiers
mkdir -p "${RESULT_FOLDER}"
mkdir -p "${LOG_FOLDER}"

# Extraction du fichier spécifique
# echo "Extraction de ${SEQ_FILE} depuis ${ARCHIVE}..."
# tar -xzf "${ARCHIVE}" -C "$(dirname "${SEQ_FILE}")" ./transcriptome.fq
# if [[ ! -f "${SEQ_FILE}" ]]; then
#     echo "Erreur : fichier ${SEQ_FILE} introuvable après extraction." >&2
#     exit 1
# fi

# Conversion FASTQ → FASTA si nécessaire
if $FASTQ; then
    echo "Conversion de ${SEQ_FILE} en FASTA..."
    . /appli/bioinfo/seqtk/1.4/env.sh
    seqtk seq -a "${SEQ_FILE}" > "${RESULT_FOLDER}/transcriptome.fasta"  # Conversion dans RESULT_FOLDER
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
busco -i "${SEQ_FILE}" -m transcriptome --offline -f -c 15 \
      -l "${DB_FOLDER}" \
      2>&1 | tee "${LOG_FOLDER}/${NAME}.log"  # Logs dans LOG_FOLDER

if [[ $? -ne 0 ]]; then
    echo "Erreur : l'exécution de BUSCO a échoué." >&2
    exit 1
fi

echo "Analyse BUSCO terminée !"
