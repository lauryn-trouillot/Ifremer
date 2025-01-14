#!/bin/bash
#PBS -N fasta_count
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=10gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement de travail
cd "${PBS_O_WORKDIR}"

CHEMIN="/home1/datawork/ltrouill/ifremer/"
LOG_FOLDER="${CHEMIN}/errors/"
LOG_FILE="$LOG_FOLDER/Nombre_sequence.log"

# Créer le dossier de logs si nécessaire
mkdir -p "$LOG_FOLDER"

# Définir les fichiers de lecture, en excluant les échantillons 2, 5, 8, 13, 14, 18
EXCLUDE="2|5|8|13|14|18"

LEFT_READS=$(ls ${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/*_R1.fastq.gz | grep -Ev "(${EXCLUDE})_R1.fastq.gz" | tr '\n' ',')
RIGHT_READS=$(ls ${CHEMIN}data/rawdata/illumina/Karlodinium_karmit/*_R2.fastq.gz | grep -Ev "(${EXCLUDE})_R2.fastq.gz" | tr '\n' ',')

# Supprimer la dernière virgule
LEFT_READS=${LEFT_READS%,}
RIGHT_READS=${RIGHT_READS%,}

# Compter le nombre total de séquences dans les fichiers de lecture (R1 et R2)
count_sequences() {
  local files=$1
  total_sequences=0
  for file in $(echo $files | tr ',' ' '); do
    # Compter le nombre de séquences en divisant par 4 les lignes de chaque fichier
    num_sequences=$(zcat $file | echo $(( $(wc -l) / 4 )))
    total_sequences=$((total_sequences + num_sequences))
  done
  echo $total_sequences
}

# Nombre total de séquences pour les fichiers R1 et R2
left_sequences=$(count_sequences "$LEFT_READS")
right_sequences=$(count_sequences "$RIGHT_READS")

# Afficher les résultats dans le fichier de log
echo "Nombre total de séquences R1: $left_sequences" >> "$LOG_FILE"
echo "Nombre total de séquences R2: $right_sequences" >> "$LOG_FILE"
echo "Nombre total de séquences (R1 + R2): $((left_sequences + right_sequences))" >> "$LOG_FILE"
