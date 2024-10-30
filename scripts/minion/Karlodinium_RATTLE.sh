#!/bin/bash
#PBS -N RATTLE_assembly
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=250:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

# Chargement de l'environnement sp�cifique pour Rattle
source /appli/bioinfo/rattle/1.0.0/env.sh

# Variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_RATTLE"
CHEMIN="/home/datawork-lpba/karlodinium/Transcriptome/RawDataTEMP/Karlodinium_RNAref-2/karlodinium_RNAref-2/20240930_1630_MN20979_ASI088_0cdfc4f6/fastq_pass/"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/ifremer/result_RATTLE"
READS="${CHEMIN}/*.fastq.gz"

# Cr�ation des dossiers de log et de r�sultats s'ils n'existent pas
mkdir -p "$LOG_FOLDER"
mkdir -p "$RESULT_FOLDER"

# Commande RATTLE
/appli/bioinfo/rattle/1.0.0/rattle cluster \
    -i "$READS" \
    --iso \
    -t 20 \
    -o "$RESULT_FOLDER" \
    2>&1 | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}.log"

# D�chargement de l'environnement Rattle
source /appli/bioinfo/rattle/1.0.0/delenv.sh

# Compression des r�sultats
tar -czvf "${RESULT_FOLDER}.tar.gz" -C "$RESULT_FOLDER" .

# Copie des r�sultats compress�s vers le dossier final
cp "${RESULT_FOLDER}.tar.gz" "/home1/datawork/ltrouill/ifremer/"
