#!/bin/bash
#PBS -N minimap
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Aller dans le répertoire de soumission
cd "${PBS_O_WORKDIR}"

# =================== DÉFINITIONS DES FICHIERS ===================

FASTQ_FILE="/home/datawork-lpba/Prymnesium/PrymneTranscripto/RNA-longReads-fev25/Galaxy43_Prymnesium_cDNA_Porechop_Qualite.fastq"
REF_FASTA="/home/datawork-lpba/Prymnesium/PrymneGenomeV1/PrymneGenomeV1.fasta"
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

if [ ! -s "$FASTQ_FILE" ]; then
    echo "Erreur : le fichier FASTQ est vide ou introuvable : $FASTQ_FILE" >> "$LOG_FILE"
    exit 1
fi


# === Préparation des noms de fichiers de sortie ===

BASENAME=$(basename "$FASTQ_FILE" .fastq)
SAM_OUT="$RESULT_FOLDER/${BASENAME}.sam"
BAM_OUT="$RESULT_FOLDER/${BASENAME}.bam"

# === CHARGEMENT ET ALIGNEMENT (minimap2 uniquement) ===

. /appli/bioinfo/minimap2/2.28/env.sh

if [ ! -f "$SAM_OUT" ]; then
    echo "Lancement de minimap2..." >> "$LOG_FILE"
    minimap2 -ax splice  -t 15 "$REF_FASTA" "$FASTQ_FILE" > "$SAM_OUT" 2>> "$LOG_FILE"
    echo "Alignement terminé." >> "$LOG_FILE"
fi

# === CHARGEMENT ET TRAITEMENT BAM (samtools uniquement) ===
. /appli/bioinfo/samtools/1.9/env.sh

if [ ! -f "$BAM_OUT" ]; then
    echo "Tri du fichier SAM avec samtools..." >> "$LOG_FILE"
    samtools sort "$SAM_OUT" -o "$BAM_OUT" 2>> "$LOG_FILE"
    echo "Tri terminé." >> "$LOG_FILE"
fi

if [ ! -f "${BAM_OUT}.bai" ]; then
    echo "Indexation du fichier BAM..." >> "$LOG_FILE"
    samtools index "$BAM_OUT" 2>> "$LOG_FILE"
    echo "Indexation terminée." >> "$LOG_FILE"
fi

# =================== NETTOYAGE (optionnel) ===================

# Uncomment if you want to delete SAM to save space:
# rm "$SAM_OUT"
