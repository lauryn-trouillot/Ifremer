#!/bin/bash
#PBS -N assembly
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=48:00:00

# Chargement de l'environnement
cd ${PBS_O_WORKDIR}

. /appli/bioinfo/trinity/2.8.5/env.sh


TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="Karlodinium_trinity"
CHEMIN="/home1/datawork/ltrouill/ifremer/"
LOG_FOLDER="${CHEMIN}/errors"

mkdir -p $LOG_FOLDER

LEFT_READS=$(ls ${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/*_R1.fastq.gz | tr '\n' ',')
RIGHT_READS=$(ls ${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/*_R2.fastq.gz | tr '\n' ',')

# Retrait de la virgule
LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

# Paramètres de la commande Trinity
seqtype="--seqType fq"
mem="--max_memory 280G"
cpu="--CPU 20"
mincontiglength="--min_contig_length 200"
output="--output ${CHEMIN}/results/illumina/Karlodinium_trinity/"
cleanup="--full_cleanup"

# Commande trinity
Trinity $seqtype $mem \
        --left $LEFT_READS \
        --right $RIGHT_READS \
        $cpu $mincontiglength \
        $output $cleanup 2>&1 | tee "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME".log