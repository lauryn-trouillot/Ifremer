
#!/bin/bash
#PBS -N minimap
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=40gb
#PBS -l walltime=72:00:00

# Ce script exécute minimap2 pour aligner des long reads sur un transcriptome.
# Il prend en entrée un fichier FASTQ de long reads et un fichier FASTA de transcriptome
# Les reads qui ne s'alignent pas sont extraits dans un fichier FASTQ compressé.

cd "${PBS_O_WORKDIR}"

# =================== DÉFINITIONS DES FICHIERS ===================

LR_FILE="Chemin/vers/les/long_reads.fastq"
TRANSCRIPTOME="Chemin/vers/le/transcriptome.fasta"
LOG_FOLDER="Chemin/vers/le/dossier/logs/minimap2/"
RESULT_FOLDER="Chemin/vers/le/dossier/minimap2_$(date +%Y%m%d_%H%M%S)"

# =================== CRÉATION DES DOSSIERS ===================

mkdir -p "$LOG_FOLDER" "$RESULT_FOLDER"

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
minimap2 -ax splice  -t 15 "$TRANSCRIPTOME" "$LR_FILE" > "$RESULT_FOLDER/Reads_to_remove.sam" 2>> "$LOG_FILE"
echo "Alignement terminé." >> "$LOG_FILE"

. /appli/bioinfo/samtools/1.9/env.sh

samtools fastq -n -f 4 "$RESULT_FOLDER/Reads_to_remove.sam" | gzip > "$RESULT_FOLDER/Reads_to_keep.fastq.gz"
