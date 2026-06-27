# 🏠 FarFromHome (AvanziZero) 🍲

<div align="center">
  <img src="flutter_app/assets/app_icon.png" alt="FarFromHome Logo" width="160" height="160" onerror="this.style.display='none'"/>
  <h3>Gestione Intelligente della Dispensa, Spesa Condivisa e Cucina a Zero Spreco per Fuorisede</h3>
  <p><i>Un'applicazione Flutter all'avanguardia alimentata da IA Ibrida Locale (DistilBERT TFLite), Motore Statistico Predittivo e Live Web Harvesting 100% Token-Less.</i></p>
</div>

---

## 🌟 Indice
- [Panoramica e Missione](#-panoramica-e-missione)
- [Architettura dell'Intelligenza Artificiale](#-architettura-dellintelligenza-artificiale)
  - [1. Scansione Scontrini: NLP Ibrido a 3 Stadi (BERT + Fuzzy)](#1-scansione-scontrini-nlp-ibrido-a-3-stadi-bert--fuzzy)
  - [2. Motore Predittivo Comportamentale (Edge Computing)](#2-motore-predittivo-comportamentale-edge-computing)
- [Motore Ricette & Live Web Harvesting](#-motore-ricette--live-web-harvesting)
- [Punti di Forza ed Ecosistema](#-punti-di-forza-ed-ecosistema)
- [Struttura del Progetto](#-struttura-del-progetto)
- [Requisiti e Installazione](#-requisiti-e-installazione)

---

## 🚀 Panoramica e Missione

**FarFromHome (AvanziZero)** nasce per rivoluzionare la gestione domestica di studenti fuorisede, coinquilini e famiglie. Coordinare la spesa, tenere traccia delle scadenze e decidere cosa cucinare con i rimasugli in frigo diventa un'esperienza fluida, automatizzata e coinvolgente.

La nostra missione è **#AvanziZero**: azzerare lo spreco alimentare sfruttando algoritmi di intelligenza artificiale eseguiti direttamente sul dispositivo, garantendo massime prestazioni, totale privacy e l'indipendenza da costosi servizi cloud a pagamento.

---

## 🧠 Architettura dell'Intelligenza Artificiale

### 1. Scansione Scontrini: NLP Ibrido a 3 Stadi (BERT + Fuzzy)
L'importazione automatica degli scontrini fotografati non si affida a un semplice OCR, ma utilizza un'avanzata pipeline ibrida orchestrata in `AIScannerService`:

```
[Immagine Scontrino] ──> 1. OCR (Google ML Kit) ──> 2. NLP NER (DistilBERT TFLite) ──> 3. Fuzzy Matching ──> [Dispensa]
```

1. **STADIO 1 - OCR (Google ML Kit Text Recognition):** Riconoscimento e frammentazione visiva dello scontrino in righe di testo grezzo.
2. **STADIO 2 - NLP Tokenization & NER (TensorFlow Lite):** Tramite un tokenizer personalizzato (`WordPieceTokenizer`) e un modello neurale compatto **DistilBERT** (`receipt_ner_distilbert.tflite`), ogni riga viene destrutturata in sub-tokens e classificata in 4 etichette NER:
   - `B-PROD` / `I-PROD`: Inizio e continuazione di un prodotto alimentare.
   - `B-QTY`: Quantità acquistata.
   - `O`: Testo irrilevante (prezzi, codici, indirizzi).
3. **STADIO 3 - Correzione Fuzzy & Post-Processing:** I testi estratti passano al `LocalReceiptParser`, che corregge istantaneamente gli errori di lettura OCR (es. trasformando _"M3LA"_ in _"Mela"_) abbinando categoria, icona e scadenza stimata.

### 2. Motore Predittivo Comportamentale (Edge Computing)
Per suggerire cosa acquistare prima di rimanere senza scorte, abbiamo implementato un **motore algoritmico locale** (`SmartPantryAI` e `LocalPredictiveModel`) che apprende dalle abitudini reali del gruppo:

- **Decadimento Temporale Esponenziale (Time Decay):** I consumi passati vengono ponderati con un peso esponenziale ($e^{-0.05 \times \text{DaysAgo}}$). Un consumo recente ha valore massimo, mentre i consumi vecchi perdono peso, catturando automaticamente stagionalità e cambi di dieta.
- **Scarcity Ratio & Frequenza:** Calcola la distanza media in giorni tra gli acquisti e l'indice di esaurimento in base al numero di coinquilini (`groupSize`).
- **Reinforcement Feedback Loop (FR6.6/FR6.7):** L'IA adatta la propria confidenza in base alle risposte dell'utente. I suggerimenti accettati guadagnano confidenza (con inserimento automatico dopo >3 accettazioni), mentre i consigli rifiutati perdono punteggio fino a entrare in una blacklist temporanea.
- **Explainable AI (XAI):** Ogni suggerimento include il motivo trasparente della predizione (es. _"Esaurimento imminente"_ o _"Frequenza di acquisto: comprato ogni ~5 giorni"_).

---

## 🍲 Motore Ricette & Live Web Harvesting

L'app risolve il problema del "cosa cucino stasera?" massimizzando l'uso di ciò che è già presente in casa, senza limiti di visualizzazione:

- **Ranking Ecologico (AvanziZero):** L'algoritmo di ordinamento mette al primo posto le ricette che utilizzano i prodotti in dispensa vicini alla scadenza o già scaduti, seguiti dal minor numero di ingredienti mancanti e dalla rapidità di preparazione.
- **Live Web Harvesting 100% Token-Less:** Attraverso il `LiveRecipeHarvestingService`, l'app interroga in tempo reale i feed dei principali blog culinari italiani (GialloZafferano, Tavolartegusto, Benedetta, Misya, ecc.).
  - **Dizionario Alimentare Controllato:** L'estrattore filtra la prosa del web tramite un dizionario anagrafico di oltre 100 veri ingredienti, scartando parole fuorvianti ("Veloce", "Varianti", "Facile").
  - **Badge ed Etichettatura Pulita:** Le ricette pescate dal web recano il badge elegante **"Live Web"** senza riferimenti commerciali intrusivi alle fonti.
- **Gestione di Rete e Fallback Offline:** In presenza di rete, il catalogo SQLite locale si aggiorna in background da Firebase Storage. In assenza di connessione, l'app passa in modo silente al database SQLite integrato garantendo **Zero Downtime**.
- **Generatore Casuale (Pulsante Dadi):** Con un clic sull'icona dei dadi, l'app compie un fetch live dal web prioritario, mescola le scoperte e offre 5 nuove idee casuali accompagnate da notifiche native `Fluttertoast`.

---

## 💎 Punti di Forza ed Ecosistema

```
 ┌─────────────────────────────────────────────────────────┐
 │                  FARFROMHOME ECOSISTEMA                 │
 ├────────────────────────────┬────────────────────────────┤
 │ ⚡ 100% Token-Less         │ Nessuna API a pagamento    │
 ├────────────────────────────┼────────────────────────────┤
 │ 🔒 Assoluta Privacy        │ AI eseguita su Smartphone  │
 ├────────────────────────────┼────────────────────────────┤
 │ 📶 Zero Downtime Fallback  │ Funziona Offline & Online  │
 ├────────────────────────────┼────────────────────────────┤
 │ 🎯 UI Premium & Native     │ Fluttertoast + Glassmorphism│
 └────────────────────────────┴────────────────────────────┘
```

---

## 📁 Struttura del Progetto

```
FarFromHome/
├── flutter_app/                     # Applicazione principale Flutter
│   ├── assets/
│   │   ├── db/recipes_catalog.db    # Database SQLite di base
│   │   └── models/                  # Modelli TFLite (DistilBERT) e Vocabolario
│   ├── lib/
│   │   ├── models/                  # AppState, ItemModel, ecc.
│   │   ├── screens/                 # UI Screens (RecipesScreen, PantryScreen, ShoppingScreen, ecc.)
│   │   ├── services/                # Logica Core: AI Scanner, Smart Pantry, Live Harvest, Firebase
│   │   ├── theme/                   # Sistema Colori e Tipografia
│   │   └── widgets/                 # Componenti UI riutilizzabili
│   └── pubspec.yaml                 # Configurazione dipendenze (tflite_flutter, fluttertoast, sqflite...)
├── scripts/                         # Script Python di supporto (build_recipe_db.py...)
└── README.md                        # Documentazione di progetto
```

---

## 💻 Requisiti e Installazione

1. **Requisiti di Sistema:**
   - [Flutter SDK](https://flutter.dev/) (versione stabile recente, es. 3.x)
   - Dispositivo Android/iOS o Emulatore configurato

2. **Clonazione e Build:**
   ```bash
   # 1. Clona il repository
   git clone https://github.com/YuliaD2609/FarFromHome.git
   cd FarFromHome/flutter_app

   # 2. Scarica le dipendenze
   flutter pub get

   # 3. Verifica l'integrità del codice
   flutter analyze

   # 4. Avvia l'applicazione sul dispositivo
   flutter run
   ```

---

<div align="center">
  <p><i>Made with ❤️ by the FarFromHome Engineering Team. Insieme verso lo #AvanziZero!</i></p>
</div>
