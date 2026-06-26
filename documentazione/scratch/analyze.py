import os
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import re
import collections

# Supporto automatico sia per il percorso di Yulia che di Vincenzo
base_dir = r"C:\Users\yulia\OneDrive\Desktop\uni\FarFromHome\documentazione"
if not os.path.exists(base_dir):
    base_dir = r"d:\Unisa\Magistrale\EMAD\FarFromHome\documentazione"

csv_path = os.path.join(base_dir, "Analisi sulle abitudini di spesa.csv")
df = pd.read_csv(csv_path)

def generate_pie_chart(series, title, filename):
    counts = series.value_counts()
    percentages = (counts / len(series)) * 100
    
    plt.figure(figsize=(6,6))
    counts.plot.pie(autopct='%1.1f%%', startangle=140)
    plt.ylabel('')
    plt.title(title)
    plt.tight_layout()
    plt.savefig(os.path.join(base_dir, filename))
    plt.close()
    
    bar_filename = filename.replace('.png', '_bar.png')
    plt.figure(figsize=(10,6))
    counts.plot.barh(color='skyblue')
    plt.title(title)
    plt.xlabel('Conteggio')
    plt.tight_layout()
    plt.savefig(os.path.join(base_dir, bar_filename))
    plt.close()
    
    print(f"=== {title} ===")
    print("Conteggi:")
    print(counts)
    print("\nPercentuali:")
    print(percentages)
    print("-" * 40)

# 1. Con quante persone vivi (Col 1)
def clean_persone(x):
    return str(x).strip()

df['Persone'] = df.iloc[:, 1].apply(clean_persone)
generate_pie_chart(df['Persone'], 'Con quante persone vivi?', 'chart_persone.png')

# 2. Chi fa la spesa (Col 2)
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
    if "coinquilini" in x:
        return "Coinquilini"
    return "Altro"

df['Chi_fa'] = df.iloc[:, 2].apply(clean_chi_fa)
generate_pie_chart(df['Chi_fa'], 'Chi fa solitamente la spesa?', 'chart_chi_fa.png')

# 3. Quanto tempo (Col 3)
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
        "non faccio",
        "tempo di un dibattito tra me e mia mamma per decidere cosa manca e cosa ci serve",
        "non la preparo",
        "non faccio la lista",
        "compro sul momento",
        "no lista"
    ]
    for ign in ignore_list:
        if ign in x:
            return None # To drop
    
    if "un po' di tempo" in x: return 40
    if "pochissimo" in x : return 2
    if "quarto d'ora" in x or x == "15 min" or x == "15 minuti" or x == "Dipende da cosa devo prendere massimo un quarto d ora": return 15
    if "mezz'ora" in x: return 30
    if "poco tempo" in x or x == "5 minuti" or x == "poco" or x == "molto poco": return 5
    if "10 minuti" in x or x == "Dieci minuti" or x == "meno di dieci minuti" or x == "5-10 minuti": return 10
    if "30 minuti" in x or x == "30 min" or x == "Dipende ma credo 1 oretta": return 30
    if "45 minuti" in x: return 45
    
    nums = re.findall(r'\d+', x)
    if nums:
        # Check if hour
        if "ora" in x or "hour" in x or "oretta" in x:
            return int(nums[0]) * 60
        return int(nums[0])
    
    if "ora" in x or "hour" in x or "oretta" in x: return 60
    if "pochi minuti" in x or "pochi secondi" in x or x == "1 minuto" or x == "molto poco": return 2
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
generate_pie_chart(df_tempo['Tempo_cat'], 'Quanto tempo impieghi a preparare la lista della spesa?', 'chart_tempo.png')

# 4. Ti pesa ricordare cosa manca (Col 4)
def clean_pesa_ricordare(x):
    x = str(x).strip().lower()
    if "si" in x: return "Sì"
    if "no" in x and "non so" not in x: return "No"
    if "non so" in x: return "Non so"
    return "Altro"

df['Pesa_ricordare'] = df.iloc[:, 4].apply(clean_pesa_ricordare)
generate_pie_chart(df['Pesa_ricordare'], 'Ti pesa ricordare cosa manca?', 'chart_pesa_ricordare.png')

# 5. Dimenticato prodotto essenziale (Col 5)
def clean_dimenticato_essenziale(x):
    x = str(x).strip().lower()
    if x == "si": return "Sì"
    if x == "no": return "No"
    return "Altro"

df['Dim_essenziale'] = df.iloc[:, 5].apply(clean_dimenticato_essenziale)
generate_pie_chart(df['Dim_essenziale'], 'Hai mai dimenticato di inserire un prodotto nella lista della spesa?', 'chart_dimenticato_essenziale.png')

# 6. Dimenticanze lista (Col 6)
def clean_dimenticanze(x):
    x = str(x).strip().lower()
    if "non faccio la lista" in x or "non lo so" in x or "non preparo la lista" in x or "non faccio liste della spesa" in x or x=="nessuna": return None
    
    if x == "mai" or "nessuna" in x: return "Mai"
    if "sempre" in x or x == "abbastanza comune" or x=="sempre perchè non la faccio" or x=="spessissimo" or x=="90%\ delle volte direi" or x=="quasi sempre": return "Sempre"
    if "spesso" in x or x=="utimamente spesso" or x=="spsso" or x=="succede spesso" or x=="2 volte su 5": return "Spesso"
    if "molte volte" in x or "comune" in x or x == "qualche volta": return "Spesso"
    if "talvolta" in x or x=="quasi mai." or x=="ogni tanto" in x or x=="non spessissimo": return "Raramente"
    if x == "poco" in x or x=="quasi mai" or x=="non spesso" or x=="non sempre" or x=="once a mounth": return "Raramente"
    
    return "Raramente"

df['Dim_lista'] = df.iloc[:, 6].apply(clean_dimenticanze)
df_dim = df.dropna(subset=['Dim_lista']).copy()
generate_pie_chart(df_dim['Dim_lista'], 'Quanto spesso dimentichi di inserire qualcosa nella lista della spesa?', 'chart_dim_lista.png')

# 7. Modalità di comunicazione (Col 7)
def clean_comm(x):
    x_orig = str(x).strip()
    x = x_orig.lower()
    res = set()
    
    if "si va insieme e se non si può andare basta su whatsapp con la chiamata normale" in x:
        res.add("WhatsApp")
        res.add("Si va insieme")
        res.add("Chiamata/A voce")
    elif "mi scordo e non comunico" in x:
        res.add("Nessuno")
    else:
        items = x.split(';')
        for i in items:
            i = i.strip()
            if "whatsapp" in i: res.add("WhatsApp")
            elif "chiamat" in i or "voce" in i or x == "dico a voce": res.add("Chiamata/A voce")
            elif "cartacea" in i: res.add("Lista cartacea")
            elif "vado" in i or "insieme" in i: res.add("Si va insieme")
            elif "app" in i or "app smartphone dedicata" in i or "app" in i or "bring" in i: res.add("Altre app dedicate")
    
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
plt.tight_layout()
plt.savefig(os.path.join(base_dir, 'chart_comunicazione.png'))
plt.close()

plt.figure(figsize=(10,6))
comm_counts.plot.barh(color='skyblue')
plt.title('Metodi di comunicazione')
plt.xlabel('Conteggio')
plt.tight_layout()
plt.savefig(os.path.join(base_dir, 'chart_comunicazione_bar.png'))
plt.close()

print("=== Metodi di comunicazione ===")
print("Conteggi:")
print(comm_counts)
print(f"\nPercentuale su {len(df)} persone:")
print(comm_percentages)
print("-" * 40)

# 8. Dimenticare prodotti in scadenza (Col 8)
def clean_dim_scadenza(x):
    x = str(x).strip().lower()
    if "mai" in x or "nessuna" in x or "rarely" in x or "raramente" in x or "molto poco" in x or "poco" in x or "poche volte" in x or "quasi mai" in x or "fortunatamente mai" in x or "quasi mai, consumo prima quelli" in x or "Mai. Consumo sempre prima della scadenza." in x:
        return "Mai"
    if "qualche volta" in x or "ogni tanto" in x or "a volte" in x or "succede" in x or "una volta al mese" in x or "poco" in x or "ogni tanto mi succede" in x or "molto raramente" in x:
        return "Qualche volta"
    if "spesso" in x or "tanto" in x or "spesso soprattutto per quanto riguarda lo yogurt" in x:
        return "Spesso"
    if "sempre"  in x or "molto spesso" in x or "tipo sempre" in x:
        return "Sempre"
    return "Qualche volta"

df['Dim_scadenza'] = df.iloc[:, 8].apply(clean_dim_scadenza)
generate_pie_chart(df['Dim_scadenza'], 'Dimentichi prodotti in scadenza?', 'chart_dim_scadenza.png')

# 9. Ti pesa ricordare le scadenze (Col 9)
def clean_pesa_scadenze(x):
    x = str(x).strip().lower()
    if "si" in x: return "Sì"
    if "no" in x and "non so" not in x: return "No"
    if "non so" in x: return "Non so"
    return "Altro"

df['Pesa_scadenze'] = df.iloc[:, 9].apply(clean_pesa_scadenze)
generate_pie_chart(df['Pesa_scadenze'], 'Ti pesa ricordare le scadenze?', 'chart_pesa_scadenze.png')

# 10. Fastidio se app analizza acquisti (Col 10)
def clean_fastidio_app(x):
    x = str(x).strip().lower()
    if "si" in x: return "Sì"
    if "no" in x and "non so" not in x: return "No"
    if "non so" in x: return "Non so"
    return "Altro"

df['Fastidio_app'] = df.iloc[:, 10].apply(clean_fastidio_app)
generate_pie_chart(df['Fastidio_app'], 'Ti da fastidio se un\'app analizza i tuoi acquisti?', 'chart_fastidio_app.png')

# 11. Disposto a usare app monitoraggio (Col 11)
def clean_disposto_app(x):
    x = str(x).strip().lower()
    if "si" in x: return "Sì"
    if "no" in x and "non so" not in x: return "No"
    if "non so" in x: return "Non so"
    return "Altro"

df['Disposto_app'] = df.iloc[:, 11].apply(clean_disposto_app)
generate_pie_chart(df['Disposto_app'], 'Saresti disposto a usare un\'app di monitoraggio?', 'chart_disposto_app.png')

# 12. Conoscere supermercati zona (Col 12)
def clean_supermercati_zona(x):
    x = str(x).strip().lower()
    if "si" in x: return "Sì"
    if "no" in x and "non so" not in x: return "No"
    if "non so" in x: return "Non so"
    return "Altro"

df['Supermercati_zona'] = df.iloc[:, 12].apply(clean_supermercati_zona)
generate_pie_chart(df['Supermercati_zona'], 'Ti piacerebbe conoscere i supermercati della tua zona?', 'chart_supermercati_zona.png')

# 13. Frequenza supermercato (Col 13)
def clean_frequenza(x):
    if "Solo una volta al mese" in str(x).strip():
        return "Una volta al mese"
    return str(x).strip()

df['Frequenza_supermercato'] = df.iloc[:, 13].apply(clean_frequenza)
generate_pie_chart(df['Frequenza_supermercato'], 'Con quale frequenza ti rechi al supermercato?', 'chart_frequenza_supermercato.png')

# 14. Funzionalità più utili (Col 14)
def clean_funzionalita(x):
    x_orig = str(x).strip()
    items = x_orig.split(';')
    res = set()
    for i in items:
        i_clean = i.strip()
        if not i_clean: continue
        i_lower = i_clean.lower()
        if "sincronizzazione" in i_lower: res.add("Sincronizzazione lista in tempo reale")
        elif "notifiche push" in i_lower: res.add("Notifiche push scadenze")
        elif "suggerimenti di ricette" in i_lower: res.add("Suggerimenti ricette da dispensa")
        elif "statistiche grafiche" in i_lower: res.add("Statistiche spese mensili")
        elif "scannerizzazione" in i_lower or "scontrin" in i_lower: res.add("Scanner scontrino automatico")

    return list(res)

all_funz = []
for f in df.iloc[:, 14].apply(clean_funzionalita):
    all_funz.extend(f)

funz_counts = pd.Series(all_funz).value_counts()
funz_percentages = (funz_counts / len(df)) * 100

plt.figure(figsize=(10,6))
funz_counts.plot.barh(color='skyblue')
plt.title('Funzionalità più utili in un\'app per la spesa')
plt.xlabel('Numero di preferenze')
plt.tight_layout()
plt.savefig(os.path.join(base_dir, 'chart_funzionalita.png'))
plt.close()

print("=== Funzionalità più utili ===")
print("Conteggi:")
print(funz_counts)
print(f"\nPercentuale su {len(df)} persone:")
print(funz_percentages)
print("-" * 40)
