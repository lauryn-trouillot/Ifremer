#!/bin/bash
#PBS -N full_transcriptome_filter
#PBS -q omp
#PBS -l ncpus=8
#PBS -l walltime=06:00:00
#PBS -l mem=64gb

# === VARIABLES À MODIFIER ===
export LC_ALL=C

TRANSCRIPTS="/home1/datawork/ltrouill/Ifremer/Results/Prymnesium/rnaspades/rnaspades_20250418_145703/transcripts.fasta"
TRANS_NAME=$(basename "$TRANSCRIPTS" .fasta)
LOGFILE="/home1/datawork/ltrouill/Ifremer/Errors/expression_filter/transcriptome_filter_$(date +%Y%m%d_%H%M%S).log"

READS_DIR="/home1/datawork/ltrouill/Ifremer/Data/Cleaned_data/Prymnesium/Short_reads/fastp_20250407_081434"
SAMPLES=("AA")  # adapter si plusieurs échantillons
EXT_R1="_R1.cleaned.fastq.gz"
EXT_R2="_R2.cleaned.fastq.gz"

# Seuils de filtrage
MIN_EXPR=1
MIN_DOM_ISO=50
HIGHEST_ONLY=1

# === Dossier de travail ===
WORKDIR="/home1/scratch/ltrouill/${TRANS_NAME}_analysis_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "=== Début du pipeline transcriptome - $(date +%Y%m%d_%H%M%S) ===" > "$LOGFILE"

# === Indexing transcriptome ===
. /appli/bioinfo/salmon/1.10.0/env.sh
if [ ! -d "$WORKDIR/salmon_index" ]; then
    echo "[+] Indexing transcriptome with Salmon..." >> "$LOGFILE"
    salmon index -t "$TRANSCRIPTS" -i "$WORKDIR/salmon_index" 2>> "$LOGFILE"
fi

# === Quantification Short Reads uniquement ===
mkdir -p "$WORKDIR/salmon_quant"

for SAMPLE in "${SAMPLES[@]}"; do
    R1="${READS_DIR}/${SAMPLE}${EXT_R1}"
    R2="${READS_DIR}/${SAMPLE}${EXT_R2}"

    if [[ -s "$R1" && -s "$R2" ]]; then
        echo "[+] Quantifying SR for sample $SAMPLE..." >> "$LOGFILE"
        salmon quant -i "$WORKDIR/salmon_index" -l A \
            -1 "$R1" -2 "$R2" \
            -p 8 --validateMappings \
            -o "$WORKDIR/salmon_quant/${SAMPLE}_SR_quant" 2>> "$LOGFILE"
    else
        echo "[!] Fichiers manquants pour $SAMPLE : $R1 ou $R2" >> "$LOGFILE"
    fi
done

# === Modules nécessaires pour Trinity ===
. /appli/bioinfo/trinity/2.15.2/env.sh
TRINITY_IMG=/appli/bioinfo/trinity/2.15.2/trinity-2.15.2.sif

# === Création gene_trans_map.tsv ===
echo "[+] Creating gene_trans_map.tsv..." >> "$LOGFILE"
awk '/^>/{gsub(">",""); split($1,a," "); split(a[1],b,"."); print b[1]"\t"a[1]}' "$TRANSCRIPTS" | sort -u > "$WORKDIR/salmon_quant/gene_trans_map.tsv"

# === Génération de la matrice TPM ===
echo "[+] Generating TPM matrix..." >> "$LOGFILE"

QUANT_LIST="$WORKDIR/quant_files_list.txt"
find "$WORKDIR/salmon_quant" -name "quant.sf" > "$QUANT_LIST"

singularity run -B $DATAWORK,$SCRATCH ${TRINITY_IMG} /usr/local/bin/util/abundance_estimates_to_matrix.pl \
    --est_method salmon \
    --quant_files "$QUANT_LIST" \
    --name_sample_by_basedir \
    --out_prefix "$WORKDIR/expression_matrix" \
    --gene_trans_map "$WORKDIR/salmon_quant/gene_trans_map.tsv" 2>> "$LOGFILE"

MATRIX="$WORKDIR/expression_matrix.isoform.TPM.not_cross_norm"

# === Filtrage final avec script Perl ===
echo "[+] Filtering transcripts with Perl script..." >> "$LOGFILE"
ARGS="--matrix $MATRIX --transcripts $TRANSCRIPTS --min_expr_any $MIN_EXPR"

if [[ "$HIGHEST_ONLY" == "1" ]]; then
    ARGS="$ARGS --highest_iso_only"
else
    ARGS="$ARGS --min_pct_dom_iso $MIN_DOM_ISO"
fi

ARGS="$ARGS --gene_to_trans_map $WORKDIR/salmon_quant/gene_trans_map.tsv"

singularity run -B $DATAWORK,$SCRATCH ${TRINITY_IMG} /usr/local/bin/util/filter_low_expr_transcripts.pl $ARGS > "$WORKDIR/filtered_transcripts.fasta" 2>> "$LOGFILE"
