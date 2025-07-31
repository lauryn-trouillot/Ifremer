# Arborescence et description des scripts Prymnesium

Ce dossier regroupe l’ensemble des scripts et sous-dossiers pour le traitement, le nettoyage, l’assemblage, l’annotation et l’analyse qualité du transcriptome de Prymnesium.

## Arborescence

```
Prymnesium/
├── Data_cleaning/
│   ├── bam_to_fastq.sh         # Conversion BAM → FASTQ
│   ├── fastp.sh                # Nettoyage des short reads Illumina
│   ├── fastplong.sh            # Nettoyage des long reads Nanopore
│   ├── fastqc.sh               # Contrôle qualité des reads
├── Assembly/
│   ├── rnaSPADES.sh            # Assemblage hybride SPAdes (Illumina + Nanopore)
│   ├── RNAbloom.sh             # Assemblage long reads avec RNAbloom
|   ├── RATTLE.sh               # Assemblage long reads avec RATTLE
│   └── Final_transcriptome/
│       ├── main.sh             # Pipeline principale d’assemblage et séparation des ARN
│       ├── evigene.sh          # Consensus des transcriptomes
│       ├── transdecoder.sh     # Séparation ARN codants/non codants
│       ├── blast.sh            # Identification des ARNr
│       ├── tRNAscanSE.sh       # Identification des ARNt
│       └── README.md           # Explication du workflow final
├── Quality_analysis/
│   ├── BUSCO.sh                # Évaluation de la complétude du transcriptome
│   ├── Bowtie2.sh              # Alignement des reads sur le transcriptome
├── Annotation/
│   ├── custom.config           # Configuration Nextflow pour annotation ORSON
```

## Description des principaux scripts

- **Data_cleaning/** : Scripts pour nettoyer et préparer les données brutes (Illumina/Nanopore).
- **Assembly/** : Scripts pour assembler le transcriptome à partir des reads nettoyés.
  - **Final_transcriptome/** : Pipeline complète pour obtenir le transcriptome final et séparer les différents types d’ARN.
- **Quality_analysis/** : Scripts pour contrôler la qualité et la complétude du transcriptome.
- **Annotation/** : Fichiers de configuration pour l’annotation fonctionnelle.

Chaque script est documenté en début de fichier pour préciser son usage et ses paramètres.

Pour plus de détails sur l'obtention du transcriptome consensus, voir le fichier `Final_transcriptome/README.md`.
