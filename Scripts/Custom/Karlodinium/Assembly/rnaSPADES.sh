#!/bin/bash 
#PBS -N rnaSPADES
#PBS -q omp
#PBS -l ncpus=20
#PBS -l mem=300gb
#PBS -l walltime=300:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}" 
. /appli/bioinfo/spades/4.0.0/env.sh

# Initialisation des variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NAME="rnaspades_${TIMESTAMP}"
LOG_FOLDER="/home1/datawork/ltrouill/ifremer/Prymnesium/Errors/rnaspades"
RESULT_FOLDER="/home1/scratch/ltrouill/${NAME}"
READS_FOLDER="/home1/datawork/ltrouill/ifremer/data/rawdata/illumina/Prymnesium/fastp_20250407_081434"
MINION_FILE="/home/datawork-lpba/Prymnesium/PrymneTranscripto/RNA-longReads-fev25/Galaxy43-[Prymnesium_cDNA Porechop OK Qualite Ok].fastq"

# Paramètres SPAdes
SPADES_THREADS=20
SPADES_MEMORY=300

# Création des répertoires si nécessaire
mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

# Combiner les fichiers de lecture Illumina
for file in "$READS_FOLDER"/*_R1.cleaned.fastq.gz; do
    cat "$file" >> "$RESULT_FOLDER/LEFT.fastq.gz"
done

for file in "$READS_FOLDER"/*_R2.cleaned.fastq.gz; do
    cat "$file" >> "$RESULT_FOLDER/RIGHT.fastq.gz"
done

# Définir les variables de lecture
LEFT_READS="$RESULT_FOLDER/LEFT.fastq.gz"
RIGHT_READS="$RESULT_FOLDER/RIGHT.fastq.gz"

# Lancement de SPAdes
echo "Début de l'assemblage avec SPAdes..." | tee -a "${LOG_FOLDER}/spades_${TIMESTAMP}.log"

spades.py \
  -1 "$LEFT_READS" \
  -2 "$RIGHT_READS" \
  --nanopore "$MINION_FILE" \
  -o "$RESULT_FOLDER" \
  --rna \
  --threads "$SPADES_THREADS" \
  --memory "$SPADES_MEMORY" \
  2>&1 | tee -a "${LOG_FOLDER}/spades_${TIMESTAMP}.log"

echo "Assemblage terminé."

