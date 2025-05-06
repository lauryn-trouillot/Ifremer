#!/bin/bash
#PBS -N nextpolish
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=100gb
#PBS -l walltime=40:00:00

cd "${PBS_O_WORKDIR}"

####################################
# Variables
####################################
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/nextpolish"
RESULT_FOLDER="/home1/scratch/ltrouill/nextpolish_$(date +%Y%m%d_%H%M%S)"
FILENAME="/home/datawork-lpba/Prymnesium/PrymneTranscripto/AssemblageGreg/ClusterRattelCustomGreg-Primnesium.fasta"
SR_FOLDER="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Prymnesium/Short_reads/fastp_20250407_081434"
LOGFILE="${LOG_FOLDER}/nextpolish_$(date +%Y%m%d_%H%M%S).log"

####################################
# Création des répertoires
####################################

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

echo "=== Début du script : $(date) ===" >"$LOGFILE"

. /appli/bioinfo/bwa/0.7.17/env.sh

bwa index "$FILENAME" >> "$LOGFILE" 2>&1

echo "[1/2] Alignement des reads courts" >> "$LOGFILE"

# Alignement des lectures Illumina avec bwa mem
bwa mem -t 16 \
    "$FILENAME" \
    "$SR_FOLDER/AA_R1.cleaned.fastq.gz" "$SR_FOLDER/AA_R2.cleaned.fastq.gz" \
    > "$RESULT_FOLDER/short.sam" 2>> "$LOGFILE"


# Vérification de l'alignement
if [ ! -f "$RESULT_FOLDER/short.sam" ]; then
    echo "Erreur : le fichier short.sam n'a pas été créé après l'alignement." >> "$LOGFILE"
    exit 1
fi

. /appli/bioinfo/samtools/1.9/env.sh

# Tri du fichier SAM en BAM
samtools sort "$RESULT_FOLDER/short.sam" -o "$RESULT_FOLDER/short.bam" >> "$LOGFILE" 2>&1

# Indexation du fichier BAM
samtools index "$RESULT_FOLDER/short.bam" >> "$LOGFILE" 2>&1

echo "[3/3] Configuration NextPolish" >> "$LOGFILE"

# Création du fichier de configuration pour NextPolish
cat <<EOF > "$RESULT_FOLDER/sgs.fofn"
$SR_FOLDER/AA_R1.cleaned.fastq.gz
$SR_FOLDER/AA_R2.cleaned.fastq.gz
EOF


cat <<EOF > "$RESULT_FOLDER/nextpolish.cfg"
[General]
job_type = local
task = 1
rewrite = yes
genome = "$FILENAME"
genome_size = auto
thread = 16
fix_start = no

[sgs_option]
sgs_fofn = $RESULT_FOLDER/sgs.fofn
sgs_map_tool = bwa
sgs_mapper_option = -t 16
sgs_align = $RESULT_FOLDER/short.bam
EOF

# Vérification du fichier de configuration
if [ ! -f "$RESULT_FOLDER/nextpolish.cfg" ]; then
    echo "Erreur : le fichier de configuration NextPolish est manquant !" >> "$LOGFILE"
    exit 1
fi

echo "[+] Lancement de NextPolish" >> "$LOGFILE"

# Chargement de l'environnement NextPolish et lancement
. /appli/bioinfo/nextpolish/1.4.1/env.sh

nextPolish "$RESULT_FOLDER/nextpolish.cfg" >> "$LOGFILE" 2>&1

echo "=== Fin du script : $(date) ===" >>"$LOGFILE"
