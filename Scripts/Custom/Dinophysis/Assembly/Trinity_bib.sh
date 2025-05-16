#!/bin/bash
#PBS -N trinity_bib
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# -----------------# 
# Load Trinity env #
# ---------------- #
. /appli/bioinfo/trinity/2.15.2/env.sh

# ---------------------------- #
# Singularity image of Trinity #
#                              # 
# DO NOT MODIFIED              #
# ---------------------------- #

# DO NOT MODIFIED
TRINITY_IMG=/appli/bioinfo/trinity/2.15.2/trinity-2.15.2.sif

# ---------------------- #
# Variable setting       #
#                        #
# ADAPT TO YOUR ANALYSIS #
# ---------------------- #

# Initialisation des variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_trinity_${TIMESTAMP}"
CHEMIN="/home1/datawork/ltrouill/ifremer/Karlodinium/"
LOG_FOLDER="${CHEMIN}errors/Trinity_errors/"
RESULT_FOLDER="${CHEMIN}results/illumina/Karlodinium_trinity_${TIMESTAMP}"

# ----------- #
# Run Trinity #
# ----------- #
cd ${PBS_O_WORKDIR}

# Créer les dossiers nécessaires
mkdir -p $LOG_FOLDER
mkdir -p $RESULT_FOLDER

SINGLE="/home1/datawork/ltrouill/ifremer/data/rawdata/minion/biblio/SRR23051312.fastq.gz"


# Paramètres Trinity
seqtype="--seqType fq"
mem="--max_memory 200G"
cpu="--CPU 15"
mincontiglength="--min_contig_length 200"
output="--output $RESULT_FOLDER"
cleanup="--full_cleanup"

echo "Lancement de Trinity avec les paramètres suivants :
- Fichier d'entrée : $SINGLE
- CPU : 15
- Mémoire : 200G
- Min Contig Length : 200
- Dossier de sortie : $RESULT_FOLDER
" | tee "$LOG_FOLDER/${TIMESTAMP}_${NAME}_params.log"

# Exécution de Trinity avec redirection du log
singularity run -B $DATAWORK,$SCRATCH ${TRINITY_IMG} Trinity $seqtype $mem \
        --single $SINGLE \
        --SS_lib_type R \
        --trimmomatic \
        $cpu $mincontiglength \
        $output $cleanup 2>&1 | tee "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME".log

