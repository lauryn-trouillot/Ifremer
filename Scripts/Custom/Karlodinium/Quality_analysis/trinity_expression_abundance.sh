#!/bin/bash
#PBS -N Expression
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=40:00:00

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
NAME="Trinity_expression_${TIMESTAMP}"
CHEMIN="/home1/datawork/ltrouill/ifremer/"
FILENAME="${CHEMIN}results/illumina/Trinity_20250106/Karlodinium_trinity_20250106_143432.Trinity.fasta"
LOG_FOLDER="${CHEMIN}errors/Trinity_expression_errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/$NAME"
READS_FOLDER="/home/ref-bioinfo/ifremer/phytox/karmit/data/raw-sequence"

# ----------- #
# Run Trinity #
# ----------- #
cd ${PBS_O_WORKDIR}

# Créer les dossiers nécessaires
mkdir -p $LOG_FOLDER
mkdir -p $RESULT_FOLDER

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

singularity run -B $DATAWORK,$SCRATCH ${TRINITY_IMG} /usr/local/bin/util/align_and_estimate_abundance.pl \
    --transcripts "$FILENAME" \
    --seqType fq \
    --left "$LEFT_READS" \
    --right "$RIGHT_READS" \
    --est_method kallisto \
    --trinity_mode \
    --output_dir "$RESULT_FOLDER" \
    --thread 15 \
    --prep_reference | tee "$LOG_FOLDER"/"$NAME".log
