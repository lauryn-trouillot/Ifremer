# Final_transcriptome

Ce dossier contient les scripts pour l’assemblage et la filtration du transcriptome final de Lingulodinium.
Pour chaque outil utilisé, un dossier et un fichier log sont créés.

## Rôle des scripts

- **main.sh**  
  Script principal qui exécute l’ensemble de la pipeline : consensus, séparation codant/non codant, identification des ARNr et ARNt, statistiques.

- **evigene.sh**  
  Fusionne plusieurs transcriptomes en un consensus, puis linéarise le fichier FASTA final.

- **transdecoder.sh**  
  Prédit les ARN codants (mRNA) et sépare les ARN non codants (ncRNA) à l’aide de TransDecoder.

- **blast.sh**  
  Identifie les ARNr (18S, 28S, 5.8S) parmi les ncRNA via BLAST, puis génère les fichiers correspondants.

- **tRNAscanSE.sh**  
  Détecte les ARNt dans les ncRNA restants avec tRNAscan-SE et sépare les tRNA des autres ncRNA.

## Fichiers générés

Dans le dossier `FINAL_RNA`, on retrouve ces différents fichiers :

- `All_RNA.fasta` : Transcriptome consensus.
- `mRNA.fasta` : ARN messagers codants.
- `ncRNA.fasta` : ARN non codants.
- `rRNA.fasta` : ARN ribosomiques.
- `tRNA.fasta` : ARN de transfert.
- `others_ncRNA.fasta` : Autres ARN non codants.

Après la commande blast pour séparer les ARN ribosomaux, un fichier de résumé est synthétisé dans le dossier de résultats blast :

- `${NAME}_summary.csv` : Statistiques des fichiers.

Les différents outils employés génèrent également des fichiers se trouvant directement dans leur propre dossier.

## Remarques

- Les scripts sont adaptés à l’infrastructure Datarmor.
- Les bases de données et chemins doivent être ajustés selon l’espèce étudiée.
