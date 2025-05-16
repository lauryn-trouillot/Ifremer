
#!/bin/bash
#SBATCH --job-name=split_longreads
#SBATCH --output=split_longreads_%j.log
#SBATCH --error=split_longreads_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00

# Modules HPC
module load minimap2
module load samtools

# Variables
GENOME_REF="genome_species1.fasta"
LONGREADS="reads_long.fastq.gz"
PREFIX="split_longreads"

# Étape 1 : Index du génome (facultatif avec minimap2, mais bon à faire pour performance)
echo "Indexation (optionnelle)..."
minimap2 -d ${GENOME_REF}.mmi $GENOME_REF

# Étape 2 : Alignement des long reads
echo "Alignement des long reads..."
minimap2 -ax map-ont -t 8 ${GENOME_REF}.mmi $LONGREADS > ${PREFIX}.sam

# Étape 3 : Conversion en BAM et tri
echo "Tri du BAM..."
samtools view -Sb ${PREFIX}.sam | samtools sort -o ${PREFIX}_sorted.bam

# Étape 4 : Séparer les reads alignés et non alignés
echo "Séparation mapped/unmapped..."
samtools view -b -F 4 ${PREFIX}_sorted.bam > ${PREFIX}_mapped.bam
samtools view -b -f 4 ${PREFIX}_sorted.bam > ${PREFIX}_unmapped.bam

# Étape 5 : Export en FASTQ gz
echo "Conversion en FASTQ gz..."
samtools fastq ${PREFIX}_mapped.bam | gzip > ${PREFIX}_species1.fastq.gz
samtools fastq ${PREFIX}_unmapped.bam | gzip > ${PREFIX}_species2.fastq.gz

echo "Terminé : reads séparés selon alignement"
