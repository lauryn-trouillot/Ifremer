#!/bin/bash 
#PBS -N Classical_fasta
#PBS -q omp
#PBS -l ncpus=15
#PBS -l mem=100gb
#PBS -l walltime=01:00:00

# Chargement de l'environnement
cd "${PBS_O_WORKDIR}"

awk '!/^>/ { printf "%s", $0; n = "\n" } 
/^>/ { print n $0; n = "" }
END { printf "%s", n }
' /home1/datawork/ltrouill/ifremer/results/illumina_minion/rnaSPADES/Karlodinium_rnaspade_20250110_155148/transcripts.fasta > /home1/datawork/ltrouill/ifremer/results/illumina_minion/rnaSPADES/Karlodinium_rnaspade_20250110_155148/transcripts_R.fasta