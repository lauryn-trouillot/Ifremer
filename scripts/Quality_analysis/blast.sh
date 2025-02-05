#!/bin/bash
#PBS -N blastdb
#PBS -q ftp
#PBS -l ncpus=8
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

. /appli/bioinfo/blast/2.12.0/env.sh
# # Initialiser les dossiers pour les logs et les sorties
# CHEMIN="/home1/datawork/ltrouill/ifremer/"
# LOG_FOLDER="${CHEMIN}errors/blast"
# OUTPUT_FOLDER="/home1/scratch/ltrouill/blast_$(date +%Y%m%d_%H%M%S)"

# # Création des dossiers si nécessaires
# mkdir -p "$LOG_FOLDER"
# mkdir -p "$OUTPUT_FOLDER"

# # Initialisation du fichier log
# LOGFILE="${LOG_FOLDER}/blast_$(date +%Y%m%d_%H%M%S).log"
cd /home1/datawork/ltrouill/ifremer/data/blastdb

wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz