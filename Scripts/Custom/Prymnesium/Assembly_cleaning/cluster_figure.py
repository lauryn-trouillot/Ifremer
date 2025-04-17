import pandas as pd
import matplotlib.pyplot as plt
import sys

cluster_file = sys.argv[1]

df = pd.read_csv(cluster_file)

plt.figure(figsize=(10,6))

plt.plot(df['Reads_nb'], df['Busco'], label='Busco VS Nombre de reads')
plt.plot(df['Reads_nb'], df['Similarity'], label='Similarité VS Nombre de reads')
plt.title("Score BUSCO et pourcentage d'alignement en fonction du nombre de reads")
plt.xlabel("Nombre de reads")
plt.ylabel("Score")
plt.legend()
plt.grid(True)

# Affichage du graphique
plt.savefig('cluster_fig.png')