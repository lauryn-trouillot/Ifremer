#!/bin/bash
#PBS -N porechop
#PBS -q omp
#PBS -l ncpus=16
#PBS -l mem=100gb
#PBS -l walltime=24:00:00

mkdir -p "/home1/datawork/ltrouill/ifremer/Karlodinium/Errors/porechop/"

python3 /home1/datawork/ltrouill/Porechop/porechop-runner.py -i /home/datawork-lpba/karlodinium/Transcriptome/RawDataTEMP/Karlodinium_cDNA.fastq \
                                                             -o /home1/scratch/ltrouill/Karlodinium_cDNA_cleaned.fastq \
                                                              > /home1/datawork/ltrouill/ifremer/Karlodinium/Errors/porechop/porechop.log 2>&1
