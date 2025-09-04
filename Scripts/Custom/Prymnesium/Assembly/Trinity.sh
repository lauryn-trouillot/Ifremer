#!/bin/bash
#PBS -N Trinity
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
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
NAME="Trinity_${TIMESTAMP}"
RESULT_FOLDER="/home1/scratch/ltrouill/$NAME"
READS_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Prymnesium/Short_reads/fastp_20250407_081434"
export TMPDIR=/home1/scratch/ltrouill/tmp_trinity
LOG_FOLDER="${RESULT_FOLDER}"

mkdir -p $TMPDIR

# ----------- #
# Run Trinity #
# ----------- #
cd ${PBS_O_WORKDIR}

# Créer les dossiers nécessaires
mkdir -p $LOG_FOLDER
mkdir -p $RESULT_FOLDER



# Exécution de Trinity
singularity run -B $DATAWORK,$SCRATCH,$TMPDIR ${TRINITY_IMG} Trinity \
    --seqType fq \
    --max_memory 100G \
    --left "$READS_FOLDER/AA_R1.cleaned.fastq.gz" \
    --right "$READS_FOLDER/AA_R2.cleaned.fastq.gz" \
    --CPU 15 \
    --min_contig_length 200 \
    --output "$RESULT_FOLDER" \
    2>&1 | tee "$LOG_FOLDER"/"$TIMESTAMP"_Trinity_restart.log
