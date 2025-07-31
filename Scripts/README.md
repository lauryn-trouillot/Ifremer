# Dossier Scripts - Organisation et arborescence

Ce dossier regroupe tous les scripts utilisés pour le traitement, l’assemblage, le nettoyage, l’annotation et l’analyse qualité des transcriptomes.

## Organisation

- **General/**  
  Contient les scripts génériques, non adaptés à une espèce particulière. Ces scripts servent d’outils de base et peuvent être réutilisés ou adaptés selon les besoins.

- **Custom/**  
  Contient un dossier par espèce étudiée (Dinophysis, Prymnesium, Karlodinium, Lingulolax, etc.). Chaque dossier regroupe les scripts spécifiques utilisés pour obtenir les résultats finaux pour l’espèce concernée.  
  Pour le détail du workflow et des scripts propres à chaque espèce, consultez le fichier `README.md` présent dans le dossier correspondant à l’espèce.

## Arborescence

```
Scripts/
├── General/
│   ├── Alignment/
│   │   └── minimap.sh           # Script d’alignement générique (retrait de contaminations, etc.)
│   ├── Data_cleaning/
│   │   ├── fastp.sh             # Nettoyage des short reads (Illumina)
│   │   ├── fastplong.sh         # Nettoyage des long reads (Nanopore)
│   │   ├── porechop.sh          # Retrait des adaptateurs Nanopore
│   │   └── bam_to_fastq.sh      # Conversion BAM → FASTQ
│   ├── Quality_analysis/
│   │   ├── fastqc.sh            # Contrôle qualité des reads
│   │   ├── BUSCO.sh             # Évaluation de la complétude du transcriptome
│   │   └── Bowtie2.sh           # Alignement des reads sur le transcriptome
│   └── Assembly/
│       ├── rnaSPADES.sh            # Assemblage hybride SPAdes (Illumina + Nanopore)
│       ├── RNAbloom.sh             # Assemblage long reads avec RNAbloom
|       ├── RATTLE.sh               # Assemblage long reads avec RATTLE
│       └── Final_transcriptome/
│           ├── main.sh             # Pipeline principale d’assemblage et séparation des ARN
│           ├── evigene.sh          # Consensus des transcriptomes
│           ├── transdecoder.sh     # Séparation ARN codants/non codants
│           ├── blast.sh            # Identification des ARNr
│           ├── tRNAscanSE.sh       # Identification des ARNt
├── Custom/
│   ├── Dinophysis/
│   ├── Prymnesium/
│   ├── Karlodinium/
│   └── Lingulolax/

```


