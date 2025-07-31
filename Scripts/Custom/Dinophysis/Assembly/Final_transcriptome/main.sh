#!/bin/bash 
#PBS -N THE_pipeline
#PBS -q omp
#PBS -l ncpus=8
#PBS -l mem=100gb
#PBS -l walltime=10:00:00

# Ce script est le script principal permettant de lancer la pipeline de traitement du transcriptome de Dinophysis.
# Il inclut les étapes de consensus des transcriptomes, de séparation des ARN codants et non codants, et d'identification des ARNr et ARNt.

cd "$PBS_O_WORKDIR"

# Définir les fichiers d'entrée
TRANSCRIPTOME_1="/home1/datawork/ltrouill/Ifremer/Results/Dinophysis/rnaspades/rnaspades_20250626_090800/transcripts.fasta"
TRANSCRIPTOME_2="/home1/datawork/ltrouill/Ifremer/Results/Dinophysis/rnabloom/rnabloom.transcripts.fasta"
NAME=Dinophysis

# Créer un dossier de résultats
RESULTS_FOLDER="/home1/scratch/ltrouill/TranscriptomeTrim_$(date +%Y%m%d_%H%M%S)"
RNA_FOLDER="$RESULTS_FOLDER/FINAL_RNA"
EVIGINE_FOLDER="$RESULTS_FOLDER/evigene"
BLAST_FOLDER="$RESULTS_FOLDER/blast"
TRANSDECODER_FOLDER="$RESULTS_FOLDER/transdecoder"
TRNASCAN_FOLDER="$RESULTS_FOLDER/trnascan"

LOG_FILE="$RESULTS_FOLDER/TranscriptomeTrim.log"

mkdir -p "$RESULTS_FOLDER" "$RNA_FOLDER" "$EVIGINE_FOLDER" "$BLAST_FOLDER" "$TRNASCAN_FOLDER" "$TRANSDECODER_FOLDER"

cd /home1/datawork/ltrouill/Ifremer/Scripts/Dinophysis/Final_transcriptome

echo "[$(date)] Début de la pipeline - Transcriptome final et séparation selon les types d'ARN" > "$LOG_FILE"

echo "[$(date)] Etape 1 - Consensus des transcriptomes" >> "$LOG_FILE"

./evigene.sh "$NAME" "$TRANSCRIPTOME_1" "$TRANSCRIPTOME_2" "$EVIGINE_FOLDER" "$RNA_FOLDER" >> "$LOG_FILE"

CONSENSUS="$RNA_FOLDER/All_RNA.fasta"

if [ -e "$CONSENSUS" ] && [ ! -s "$CONSENSUS" ]; then
  echo "[ERROR] : Le fichier $CONSENSUS est vide" >> "$LOG_FILE"
  exit 1
elif [ ! -e "$CONSENSUS" ]; then
  echo "[ERROR] : Le fichier $CONSENSUS n'existe pas" >> "$LOG_FILE"
  exit 1
else
  echo "Le fichier $CONSENSUS existe et n'est pas vide" >> "$LOG_FILE"
fi

cd /home1/datawork/ltrouill/Ifremer/Scripts/Dinophysis/Final_transcriptome

echo "[$(date)] Etape 2 - Détéction des ARN codant avec TransDecoder" >> "$LOG_FILE"

./transdecoder.sh "$CONSENSUS" "$TRANSDECODER_FOLDER" "$RNA_FOLDER" >> "$LOG_FILE"

# Chemin vers les ARN non codants
NC_RNA="$RNA_FOLDER/ncRNA.fasta"

if [ -e "$NC_RNA" ] && [ ! -s "$NC_RNA" ]; then
  echo "[ERROR] : Le fichier $NC_RNA est vide" >> "$LOG_FILE"
  exit 1
elif [ ! -e "$NC_RNA" ]; then
  echo "[ERROR] : Le fichier $NC_RNA n'existe pas" >> "$LOG_FILE"
  exit 1
else
  echo "Le fichier $NC_RNA existe et n'est pas vide" >> "$LOG_FILE"
fi

echo "[$(date)] Etape 3 - Séparation par type d'ARN" >> "$LOG_FILE"

echo "[$(date)] Etape 3.1 - Identification des ARNr" >> "$LOG_FILE"

./blast.sh "$NAME" "$NC_RNA" "$BLAST_FOLDER" "$RNA_FOLDER" >> "$LOG_FILE"

# Chemin vers les ARN non codants sans les ARNr
NON_RRNA="$RNA_FOLDER/nonrRNA.fasta"

if [ -e "$NON_RRNA" ] && [ ! -s "$NON_RRNA" ]; then
  echo "[ERROR] : Le fichier $NON_RRNA est vide" >> "$LOG_FILE"
  exit 1
elif [ ! -e "$NON_RRNA" ]; then
  echo "[ERROR] : Le fichier $NON_RRNA n'existe pas" >> "$LOG_FILE"
  exit 1
else
  echo "Le fichier $NON_RRNA existe et n'est pas vide" >> "$LOG_FILE"
fi

echo "[$(date)] Etape 3.2 - Identification des ARNt" >> "$LOG_FILE"

./tRNAscanSE.sh "$NON_RRNA" "$TRNASCAN_FOLDER" "$RNA_FOLDER" >> "$LOG_FILE"

OTHERS_ncRNA="$RNA_FOLDER/others_ncRNA.fasta"

if [ -e "$OTHERS_ncRNA" ] && [ ! -s "$OTHERS_ncRNA" ]; then
  echo "[ERROR] : Le fichier $OTHERS_ncRNA est vide" >> "$LOG_FILE"
  exit 1
elif [ ! -e "$OTHERS_ncRNA" ]; then
  echo "[ERROR] : Le fichier $OTHERS_ncRNA n'existe pas" >> "$LOG_FILE"
  exit 1
else
  echo "Le fichier $OTHERS_ncRNA existe et n'est pas vide" >> "$LOG_FILE"
  rm "$NON_RRNA"
fi

echo "[$(date)] Etape 4 - Statistiques des fichiers"

. /appli/bioinfo/seqkit/2.9.0/env.sh

seqkit stats -a "$RNA_FOLDER"/*.fa* --out-file "$RNA_FOLDER/${NAME}_summary.csv" --csv 

echo "[$(date)] Fin de la pipeline" >> "$LOG_FILE"




