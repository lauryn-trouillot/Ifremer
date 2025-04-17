#!/bin/bash
#PBS -N tophat
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Pour l'alignement de short reads RNA-seq sur un génome

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

# Initialiser les dossiers pour les logs et les sorties
READS1="/home/ref-bioinfo/ifremer/phytox/p-parvum-mixotrophie/data/raw-sequence/AA_R1.fastq.gz"
READS2="/home/ref-bioinfo/ifremer/phytox/p-parvum-mixotrophie/data/raw-sequence/AA_R2.fastq.gz"
REF_FASTA="/home/datawork-lpba/Prymnesium/PrymneGenomeV1/PrymneGenomeV1.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/tophat/"
RESULT_FOLDER="/home1/scratch/ltrouill/tophat_$(date +%Y%m%d_%H%M%S)"
LOGFILE="${LOG_FOLDER}/tophat_$(date +%Y%m%d_%H%M%S).log"

# Créer les dossiers si nécessaire
mkdir -p "$LOG_FOLDER"
mkdir -p "$RESULT_FOLDER"

echo "Chargement de Bowtie2..." >>"$LOGFILE"
. /appli/bioinfo/bowtie2/2.5.4/env.sh

# Index the reference genome
echo "--- Construction de l'index Bowtie2 ---" >>"$LOGFILE"
INDEX_PREFIX="${RESULT_FOLDER}/transcript_index"
bowtie2-build "$REF_FASTA" "$INDEX_PREFIX" >>"$LOGFILE" 2>&1
echo "Construction terminée" >>"$LOGFILE"

echo "Chargement de Tophat2..." >>"$LOGFILE"
. /appli/bioinfo/tophat2/2.1.1/env.sh

echo "--- Exécution de Tophat2 ---" >>"$LOGFILE"
tophat -p 8 -o "$RESULT_FOLDER" --no-novel-junc "$INDEX_PREFIX" "$READS1" "$READS2" >>"$LOGFILE" 2>&1
echo "Exécution terminée" >>"$LOGFILE"