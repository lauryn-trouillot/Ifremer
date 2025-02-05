#!/bin/bash

# Fonction pour obtenir la longueur maximale d'un read dans un fichier FASTA ou FASTQ
get_max_length() {
    local file="$1"
    local max_length=0
    local max_name=""

    # Vérifie le format du fichier (FASTA ou FASTQ)
    if [[ "$(head -n 1 "$file")" == "@"* ]]; then

        # Parcours du fichier par groupes de 4 lignes
        awk 'NR % 4 == 1 { name = $0 }
             NR % 4 == 2 { 
                if (length($0) > max_length) { 
                    max_length = length($0)
                    max_name = name
                } 
            } END { 
                print max_length, max_name 
            }' "$file"
    else

        # Parcours du fichier FASTA pour calculer la longueur maximale
        awk 'BEGIN { seq = ""; name = "" }
        /^>/ { 
            if (seq != "") {
                if (length(seq) > max_length) { 
                    max_length = length(seq)
                    max_name = name
                }
            }
            name = $0
            seq = ""
        }
        /^[^>]/ { 
            seq = seq $0 
        }
        END { 
            if (length(seq) > max_length) { 
                max_length = length(seq)
                max_name = name
            }
            print max_length, max_name 
        }' "$file"
    fi
}

# Fonction pour obtenir la longueur minimale d'un read dans un fichier FASTA ou FASTQ
get_min_length() {
    local file="$1"
    local min_length=0
    local min_name=""

    # Vérifie le format du fichier (FASTA ou FASTQ)
    if [[ "$(head -n 1 "$file")" == "@"* ]]; then

        # Parcours du fichier par groupes de 4 lignes
        awk 'NR % 4 == 1 { name = $0 }
             NR % 4 == 2 { 
                if (length($0) < min_length || min_length == 0) { 
                    min_length = length($0)
                    min_name = name
                } 
            } END { 
                print min_length, min_name 
            }' "$file"
    else

        # Parcours du fichier FASTA pour calculer la longueur minimale
        awk 'BEGIN { seq = ""; name = "" }
        /^>/ { 
            if (seq != "") {
                if (length(seq) < min_length || min_length == 0) { 
                    min_length = length(seq)
                    min_name = name
                }
            }
            name = $0
            seq = ""
        }
        /^[^>]/ { 
            seq = seq $0 
        }
        END { 
            if (length(seq) < min_length || min_length == 0) { 
                min_length = length(seq)
                min_name = name
            }
            print min_length, min_name 
        }' "$file"
    fi
}

# Fonction pour obtenir la longueur moyenne d'un read dans un fichier FASTA ou FASTQ
get_average_length() {
    local file="$1"
    local total_length=0
    local num_reads=0

    if [[ "$(head -n 1 "$file")" == "@"* ]]; then
        # Utiliser awk pour parcourir le fichier et additionner les longueurs des séquences
        total_length=$(awk 'NR % 4 == 2 { total_length += length($0); num_reads++ } END { print total_length }' "$file")
        num_reads=$(awk 'NR % 4 == 2 { num_reads++ } END { print num_reads }' "$file")

        # Calculer la longueur moyenne
        if [ "$num_reads" -gt 0 ]; then
            average_length=$((total_length / num_reads))
            echo "$average_length"
        else
            echo "0"
        fi
    else
        total_length=$(awk 'BEGIN { seq = "" }
        /^>/ { 
            if (seq != "") {
                total_length += length(seq)
                num_reads++
            }
            seq = ""
        }
        /^[^>]/ { 
            seq = seq $0 
        }
        END { 
            if (seq != "") {
                total_length += length(seq)
                num_reads++
            }
            print total_length 
        }' "$file")
        num_reads=$(awk 'BEGIN { seq = "" }
        /^>/ { 
            if (seq != "") {
                num_reads++
            }
            seq = ""
        }
        /^[^>]/ { 
            seq = seq $0 
        }
        END { 
            if (seq != "") {
                num_reads++
            }
            print num_reads 
        }' "$file")

        # Calculer la longueur moyenne
        if [ "$num_reads" -gt 0 ]; then
            average_length=$((total_length / num_reads))
            echo "$average_length"
        else
            echo "0"
        fi
    fi
}

count_nt() {
    local file="$1"
    local A=0
    local T=0
    local C=0
    local G=0

    if [[ "$(head -n 1 "$file")" == "@"* ]]; then
        awk 'NR % 4 == 2 { 
        A += gsub(/A/, ""); 
        T += gsub(/T/, ""); 
        C += gsub(/C/, ""); 
        G += gsub(/G/, ""); 
        } END { print A, T, C, G }' "$file"
    else
        awk 'BEGIN { seq = "" }
        /^>/ { 
            if (seq != "") {
                A += gsub(/A/, "", seq); 
                T += gsub(/T/, "", seq); 
                C += gsub(/C/, "", seq); 
                G += gsub(/G/, "", seq); 
            }
            seq = ""
        }
        /^[^>]/ { 
            seq = seq $0 
        }
        END { 
            if (seq != "") {
                A += gsub(/A/, "", seq); 
                T += gsub(/T/, "", seq); 
                C += gsub(/C/, "", seq); 
                G += gsub(/G/, "", seq); 
            }
            print A, T, C, G 
        }' "$file"
    fi
}