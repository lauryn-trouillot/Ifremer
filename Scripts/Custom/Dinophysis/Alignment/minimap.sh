
#!/bin/bash
#PBS -N minimap
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Aller dans le répertoire de soumission
cd "${PBS_O_WORKDIR}"

# =================== DÉFINITIONS DES FICHIERS ===================

LR_FILE="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Dinophysis/fastplong_20250527_120739/Dinophysis_cDNA_porechop_fastplong.fastq"
TRANSCRIPTOME="/home1/datawork/ltrouill/Ifremer/Data/Bibliography/mesodinium_chamaeleon_nrmc1802.transcriptome.fasta"
GENOME="/home/datawork-lpba/Teleaulax/Genome_JGI/Teleaulax_JGI_GenomeV1.fasta"
LOG_FOLDER="/home1/datawork/ltrouill/Ifremer/Errors/minimap2/"
RESULT_FOLDER="/home1/scratch/ltrouill/minimap2_$(date +%Y%m%d_%H%M%S)"

# =================== CRÉATION DES DOSSIERS ===================

EXISTING_FOLDER=$(ls -d /home1/scratch/ltrouill/minimap2_20* 2>/dev/null | tail -n 1)

if [ -n "$EXISTING_FOLDER" ]; then
    echo "Un dossier existant a été trouvé : $EXISTING_FOLDER"
    RESULT_FOLDER="$EXISTING_FOLDER"
else
    mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"
fi

# =================== LOG ===================

LOG_FILE="$LOG_FOLDER/minimap2_$(date +%Y%m%d_%H%M%S).log"
echo "Début de la pipeline : minimap2" > "$LOG_FILE"

# =================== VÉRIFICATION DU FICHIER FASTQ ===================

if [ ! -s "$LR_FILE" ]; then
    echo "Erreur : le fichier FASTQ est vide ou introuvable : $LR_FILE" >> "$LOG_FILE"
    exit 1
fi

# === CHARGEMENT ET ALIGNEMENT (minimap2 uniquement) ===

. /appli/bioinfo/minimap2/2.28/env.sh

echo "Lancement de minimap2..." >> "$LOG_FILE"
minimap2 -ax splice  -t 15 "$TRANSCRIPTOME" "$LR_FILE" > "$RESULT_FOLDER/Reads_Mesodinium.sam" 2>> "$LOG_FILE"
echo "Alignement terminé." >> "$LOG_FILE"

. /appli/bioinfo/samtools/1.9/env.sh

samtools fastq -n -f 4 "$RESULT_FOLDER/Reads_Mesodinium.sam" | gzip > "$RESULT_FOLDER/DiNoMeso.fastq.gz"

. /appli/bioinfo/minimap2/2.28/env.sh

echo "Lancement de minimap2..." >> "$LOG_FILE"
minimap2 -ax splice  -t 15 "$GENOME" "$RESULT_FOLDER/DiNoMeso.fastq.gz" > "$RESULT_FOLDER/Reads_Teleau.sam" 2>> "$LOG_FILE"
echo "Alignement terminé." >> "$LOG_FILE"

. /appli/bioinfo/samtools/1.9/env.sh

samtools fastq -n -f 4 "$RESULT_FOLDER/Reads_Teleau.sam" | gzip >  "$RESULT_FOLDER/DiNoPrey.fastq.gz"
