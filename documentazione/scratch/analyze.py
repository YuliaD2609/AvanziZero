import pandas as pd
import matplotlib.pyplot as plt
import re
import collections

df = pd.read_csv(r"C:\Users\yulia\OneDrive\Desktop\uni\FarFromHome\documentazione\Analisi sulle abitudini di spesa.csv")

# 1. Chi fa la spesa
def clean_chi_fa(x):
    x_orig = str(x).strip()
    x = x_orig.lower()
    tutti_group = [
        "sia io che mia mamma",
        "insieme con mia madre",
        "i miei, ma a volte anche io",
        "io e mio marito",
        "tutti"
    ]
    for t in tutti_group:
        if t in x:
            return "Tutti"
    if x == "io":
        return "Io"
    if "genitore" in x or "i miei" in x:
        return "Genitori"
    if "coinquilin" in x:
        return "Coinquilini"
    return "Altro"

df['Chi_fa'] = df.iloc[:, 2].apply(clean_chi_fa)

# 2. Quanto tempo
def clean_tempo(x):
    x_orig = str(x).strip()
    x = x_orig.lower()
    
    ignore_list = [
        "non la faccio",
        "no lista",
        "ho una lista standard fatta a inizio anno",
        "non lo so, perché è mia madre che fa la lista",
        "non preparo la lista",
        "compro sul momento",
        "non preparo",
        "non faccio"
    ]
    for ign in ignore_list:
        if ign in x:
            return None # To drop
    
    if "un po' di tempo" in x: return 40
    if "pochissimo" in x or x == "poco": return 2
    if "quarto d ora" in x: return 15
    if "mezz'ora" in x: return 30
    
    nums = re.findall(r'\d+', x)
    if nums:
        # Check if hour
        if "ora" in x or "hour" in x or "oretta" in x:
            return int(nums[0]) * 60
        return int(nums[0])
    
    if "ora" in x or "hour" in x or "oretta" in x: return 60
    if "pochi minuti" in x or "pochi secondi" in x: return 2
    if "qualche minuto" in x: return 5

    return None

df['Tempo_val'] = df.iloc[:, 3].apply(clean_tempo)
df_tempo = df.dropna(subset=['Tempo_val']).copy()

def group_tempo(v):
    if v <= 5: return "0-5 minuti"
    if v <= 15: return "6-15 minuti"
    if v <= 30: return "16-30 minuti"
    return "Più di 30 minuti"

df_tempo['Tempo_cat'] = df_tempo['Tempo_val'].apply(group_tempo)

# 3. Dimenticanze lista (Col 7)
def clean_dimenticanze(x):
    x = str(x).strip().lower()
    if "non faccio la lista" in x or "non lo so" in x: return None
    
    if x == "mai" or "nessuna" in x: return "Mai"
    if "sempre" in x and "quasi mai" not in x: return "Sempre"
    if "spesso" in x and "non spesso" not in x: return "Spesso"
    if "molte volte" in x or "comune" in x: return "Spesso"
    
    return "Raramente"

df['Dim_lista'] = df.iloc[:, 6].apply(clean_dimenticanze)
df_dim = df.dropna(subset=['Dim_lista']).copy()

# 4. Modalità di comunicazione (Col 8)
def clean_comm(x):
    x_orig = str(x).strip()
    x = x_orig.lower()
    res = set()
    
    if "si va insieme e se non si può andare basta su whatsapp con la chiamata normale" in x:
        res.add("WhatsApp")
        res.add("Si va insieme")
        res.add("Chiamata/A voce")
    elif "mi scordo e non comunico" in x:
        res.add("Nessuna/Dimentico")
    else:
        items = x.split(';')
        for i in items:
            i = i.strip()
            if "whatsapp" in i: res.add("WhatsApp")
            elif "chiamat" in i or "voce" in i: res.add("Chiamata/A voce")
            elif "cartacea" in i: res.add("Lista cartacea")
            elif "vado" in i or "insieme" in i: res.add("Si va insieme")
            elif "app" in i or "bring" in i: res.add("Altre app dedicate")
    
    return list(res)

all_comms = []
for c in df.iloc[:, 7].apply(clean_comm):
    all_comms.extend(c)

comm_counts = pd.Series(all_comms).value_counts()
comm_percentages = (comm_counts / len(df)) * 100

plt.figure(figsize=(6,6))
comm_counts.plot.pie(autopct='%1.1f%%', startangle=140)
plt.ylabel('')
plt.title('Metodi di comunicazione')
plt.savefig(r'C:\Users\yulia\OneDrive\Desktop\uni\FarFromHome\documentazione\chart_comunicazione.png')
plt.close()

print("Comunicazione (conteggi):")
print(comm_counts)
print("\nComunicazione (percentuale su 51 persone):")
print(comm_percentages)
