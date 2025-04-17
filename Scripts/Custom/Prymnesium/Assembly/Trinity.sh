#!/bin/bash
#PBS -N Trinity
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
NAME="Trinity_Prymne_${TIMESTAMP}"
CHEMIN="/home1/datawork/ltrouill/ifremer/Prymnesium"
LOG_FOLDER="${CHEMIN}/Errors/Trinity_errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/trinity_${TIMESTAMP}"
READS_FOLDER="/home1/datawork/ltrouill/ifremer/data/rawdata/illumina/Prymnesium/fastp_20250407_081434"

# ----------- #
# Run Trinity #
# ----------- #
cd ${PBS_O_WORKDIR}

# Créer les dossiers nécessaires
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"


LEFT_READS=$(ls "${READS_FOLDER}"/*_R1.cleaned.fastq.gz | tr '\n' ',')
RIGHT_READS=$(ls "${READS_FOLDER}"/*_R2.cleaned.fastq.gz | tr '\n' ',')

# Supprimer la dernière virgule
LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

# Paramètres Trinity
seqtype="--seqType fq"
mem="--max_memory 300G"
cpu="--CPU 15"
mincontiglength="--min_contig_length 200"
output="--output $RESULT_FOLDER"
cleanup="--full_cleanup"

# Exécution de Trinity
singularity run -B $DATAWORK,$SCRATCH, $DATAREF ${TRINITY_IMG} Trinity $seqtype $mem \
        --left $LEFT_READS \
        --right $RIGHT_READS \
        $cpu $mincontiglength \
        $output $cleanup 2>&1 | tee "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME".log
