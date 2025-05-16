#!/bin/bash
#PBS -N assembly
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
CHEMIN="/home1/datawork/ltrouill/ifremer/"
LOG_FOLDER="${CHEMIN}/errors/Trinity_errors/"
RESULT_FOLDER="/home1/scratch/ltrouill/Karlodinium_trinity_${TIMESTAMP}"

# ----------- #
# Run Trinity #
# ----------- #
cd ${PBS_O_WORKDIR}

# Créer les dossiers nécessaires
mkdir -p $LOG_FOLDER
mkdir -p $RESULT_FOLDER

# Définir les fichiers de lecture, en excluant les échantillons 2, 5, 8, 13, 14, 18
EXCLUDE="2|5|8|13|14|18"

LEFT_READS=$(ls ${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/*_R1.fastq.gz | grep -Ev "(${EXCLUDE})_R1.fastq.gz" | tr '\n' ',')
RIGHT_READS=$(ls ${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/*_R2.fastq.gz | grep -Ev "(${EXCLUDE})_R2.fastq.gz" | tr '\n' ',')

# Supprimer la dernière virgule
LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

# Paramètres Trinity
seqtype="--seqType fq"
mem="--max_memory 200G"
cpu="--CPU 15"
mincontiglength="--min_contig_length 200"
output="--output $RESULT_FOLDER"
cleanup="--full_cleanup"

# Exécution de Trinity avec redirection du log
singularity run -B $DATAWORK,$SCRATCH ${TRINITY_IMG} Trinity $seqtype $mem \
        --left $LEFT_READS \
        --right $RIGHT_READS \
        $cpu $mincontiglength \
        $output $cleanup 2>&1 | tee "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME".log

# Vérifier si Trinity a réussi (code de sortie 0)
if [ $? -eq 0 ]; then
    echo "Trinity a réussi, compression et copie en cours..."

    # Créer une archive tar.gz du répertoire de résultats
    tar -czvf "${RESULT_FOLDER}.tar.gz" "$RESULT_FOLDER"

    # Copier l'archive vers le répertoire de destination sur $DATAWORK
    cp "${RESULT_FOLDER}.tar.gz" "${CHEMIN}/results/"

    # Supprimer le dossier de résultats de scratch après copie
    rm -rf "$RESULT_FOLDER"
    echo "Dossier de travail supprimé de $SCRATCH."
else
    echo "Erreur : Trinity n'a pas fonctionné correctement. Aucune action de compression, de copie ou de suppression ne sera effectuée."
fi
