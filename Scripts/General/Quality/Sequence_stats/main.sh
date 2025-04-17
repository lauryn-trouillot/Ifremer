#!/bin/bash

source functions.sh

nb_param=$#
if [ $nb_param -ge 1 ]; then 
    if [ -f "$1" ]; then
        case "$1" in
            *.fasta.gz)
            Nb_reads=$(zgrep '^>' "$1" | wc -l)
            Longueur_max=$(gzip -dc "$1" | get_max_length "$1")
            Longueur_min=$(gzip -dc "$1" | get_min_length "$1")
            Longueur_moyenne=$(gzip -dc "$1" | get_average_length "$1")
            read -r A T C G <<< $(gzip -dc "$1" | count_nt "$1")
            ;;
            *.fastq.gz)
            Nb_reads=$(( $(zcat "$1" | wc -l ) / 4 ))
            Longueur_max=$(gzip -dc "$1" | get_max_length "$1")
            Longueur_min=$(gzip -dc "$1" | get_min_length "$1")
            Longueur_moyenne=$(gzip -dc "$1" | get_average_length "$1")
            read -r A T C G <<< $(gzip -dc "$1" | count_nt "$1")
            ;;
            *.fasta)
            Nb_reads=$(grep '^>' "$1" | wc -l)
            Longueur_max=$(get_max_length "$1")
            Longueur_min=$(get_min_length "$1")
            Longueur_moyenne=$(get_average_length "$1")
            read -r A T C G <<< $(count_nt "$1")
            ;;
            *.fastq)
            Nb_reads=$(( $(cat "$1" | wc -l ) / 4 ))
            Longueur_max=$(get_max_length "$1")
            Longueur_min=$(get_min_length "$1")
            Longueur_moyenne=$(get_average_length "$1")
            read -r A T C G <<< $(count_nt "$1")
            ;;
            *)
            echo "'$1' n'est pas au bon format"
            ;;
        esac 

        total_nt=$((A + T + C + G))
        pct_A=$(echo "scale=2; $A / $total_nt * 100" | bc)
        pct_T=$(echo "scale=2; $T / $total_nt * 100" | bc)
        pct_C=$(echo "scale=2; $C / $total_nt * 100" | bc)
        pct_G=$(echo "scale=2; $G / $total_nt * 100" | bc)
        pct_GC=$(echo "scale=2; ($C + $G) / $total_nt * 100" | bc)

        echo "Nombre de reads : $Nb_reads"
        echo "Longueur maximale : $Longueur_max"
        echo "Longueur minimale : $Longueur_min"
        echo "Longueur moyenne : $Longueur_moyenne"
        echo "Nombre de A : $A ($pct_A%)"
        echo "Nombre de T : $T ($pct_T%)"
        echo "Nombre de C : $C ($pct_C%)"
        echo "Nombre de G : $G ($pct_G%)"
        echo "Pourcentage de GC : $pct_GC%"
    else 
        exit 1 
    fi
else 
    echo "Veuillez indiquer le format du fichier fasta ou fastq"
fi