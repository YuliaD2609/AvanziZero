# 🏠 AvanziZero (AvanziZero) 🍲

<div align="center">
  <img src="flutter_app/assets/images/logo.png" alt="AvanziZero Logo" width="180" height="180" onerror="this.style.display='none'"/>
  <h3>La Prima Super-App per Studenti Fuorisede e Coinquilini: Spesa Condivisa, Dispensa Intelligente e Cucina a #AvanziZero</h3>
  <p><i>Gestisci la casa in armonia, risparmia tempo e denaro, azzera gli sprechi alimentari e scopri migliaia di ricette perfette per ciò che hai in frigo.</i></p>
</div>

---

## 🌟 Indice
- [🌍 Il Contesto Sociale & Il Problema dello Spreco](#-il-contesto-sociale--il-problema-dello-spreco)
  - [Situazione Sociale ed Economica](#situazione-sociale-ed-economica)
  - [I Limiti degli Strumenti Attuali](#i-limiti-degli-strumenti-attuali)
- [🤖 Architettura di Intelligenza Artificiale (Edge Computing)](#-architettura-di-intelligenza-artificiale-edge-computing)
  - [Modelli TFLite (DistilBERT) & Scansione Scontrini](#modelli-tflite-distilbert--scansione-scontrini)
  - [Motore Predittivo Comportamentale (Smart Pantry AI)](#motore-predittivo-comportamentale-smart-pantry-ai)
- [📱 Esplorazione delle Funzionalità Chiave](#-esplorazione-delle-funzionalità-chiave)
  - [📦 1. La Dispensa Smart & Condivisa](#1-la-dispensa-smart--condivisa)
  - [📸 2. Importazione Magica Scontrini con IA On-Device](#2-importazione-magica-scontrini-con-ia-on-device)
  - [🛒 3. Lista della Spesa Sincronizzata & Suggerimenti Intelligenti](#3-lista-della-spesa-sincronizzata--suggerimenti-intelligenti)
  - [🍲 4. Ricettario #AvanziZero & Il "Grandissimo Retrieve" dal Web](#4-ricettario-avanzizero--il-grandissimo-retrieve-dal-web)
  - [👥 5. Gestione Gruppi & Coinquilini](#5-gestione-gruppi--coinquilini)
  - [📍 6. Radar Supermercati Vicini](#6-radar-supermercati-vicini)
  - [🎨 7. Esperienza Fluida: Animazione Iniziale & Premium Mode](#7-esperienza-fluida-animazione-iniziale--premium-mode)
- [🌿 L'Impatto Ambientale e Sociale (#AvanziZero)](#-limpatto-ambientale-e-sociale-avanzizero)
- [🛡️ L'Esperienza Utente: Offline-First e Privacy Totale](#-lesperienza-utente-offline-first-e-privacy-totale)
- [💻 Guida all'Installazione per Sviluppatori](#-guida-allinstallazione-per-sviluppatori)

---

## 🌍 Il Contesto Sociale & Il Problema dello Spreco

Un'analisi approfondita del sistema corrente e delle interviste condotte con gli utenti evidenzia dinamiche critiche, specialmente nelle fasce più giovani e dinamiche della società.

### Situazione Sociale ed Economica

Il fenomeno dello spreco alimentare domestico rappresenta una problematica globale con un forte impatto sia ecologico che economico:

* **Impatto delle famiglie:** I nuclei familiari rappresentano il motore principale dello spreco alimentare globale, generando il **53%** dei rifiuti alimentari totali. Nel contesto italiano, le rilevazioni indicano che lo spreco domestico settimanale ammonta a **554 grammi a famiglia**, corrispondenti a circa **79,14 grammi a persona**.
* **Gestione delle scadenze e pianificazione:** Studi condotti dall'Unione Europea e dalla Food and Drug Administration stimano che circa il **10%** dello spreco in Europa e fino al **20%** in America sia direttamente collegato all'errata interpretazione delle date di scadenza. Sorprendentemente, solo il **35%** delle famiglie controlla il frigorifero prima di effettuare nuovi acquisti.
* **Il ruolo della Generazione Z:** I giovani (fascia 14-30 anni) costituiscono il segmento demografico con la minore efficienza gestionale e la maggiore propensione allo spreco. Tali comportamenti sono fortemente associati allo stile di vita transitorio dei fuorisede e al frequente ricorso ad applicazioni di food delivery, elementi che riflettono una convenienza immediata e una totale disconnessione dalla gestione della dispensa domestica.
* **Inefficienza economica e temporale:** Il **22%** delle risorse finanziarie destinate alla spesa alimentare viene vanificato a causa di inefficienze nella pianificazione, conservazione e gestione logistica. Le persone oggigiorno risentono di una cronica mancanza di tempo e di una percezione distorta dei costi reali. Di conseguenza, circa il **50%** delle persone ammette di dimenticare il cibo acquistato all'interno del frigo fino all'inevitabile superamento della data di scadenza.

---

### I Limiti degli Strumenti Attuali

La gestione domestica condivisa si basa attualmente su strumenti frammentati e non ottimizzati:

* **WhatsApp:** Usato come lista condivisa improvvisata. I messaggi si perdono nel flusso costante di conversazioni. Nessuna struttura, nessun inventario, nessuna predizione.
* **Note generiche:** Liste digitali semplici (spesso appunti nativi del telefono), non collaborative, completamente prive di logica di categorizzazione o alert scadenze.
* **Carta e penna / lavagna:** Massimo controllo fisico in cucina ma zero condivisione digitale, rendendo l'inventario inaccessibile da remoto quando ci si trova tra le corsie del supermercato.
* **Memoria individuale:** Il metodo più diffuso ma il meno affidabile in assoluto. È la causa principale di acquisti doppi (*"Pensavo l'avessi preso tu!"*), dimenticanze e prodotti scaduti non rilevati.

**La conclusione è chiara:** Nessuno strumento attuale integra inventario, alert scadenze, collaborazione real-time e predizione IA in un'unica piattaforma dedicata. **AvanziZero** nasce proprio per colmare questo vuoto tecnologico e sociale.

---

## 🤖 Architettura di Intelligenza Artificiale (Edge Computing)

AvanziZero adotta un'architettura **Edge Computing**, portando il computing neurale direttamente a bordo dello smartphone dell'utente, azzerando la latenza di rete e azzerando i costi di API esterne (100% Token-Less).

```mermaid
flowchart TD
    subgraph Edge Computing On-Device
        A[📸 Fotografia Scontrino] -->|Google ML Kit| B[Motore OCR]
        B -->|Testo Grezzo| C[DistilBERT in TFLite]
        C -->|Fuzzy Matching & Parser| D[Identificazione Prodotto & Scadenza]
        D --> E[📦 Dispensa Smart Condivisa]
        E -->|Analisi Pattern Consumo| F[Smart Pantry AI Predittivo]
        F -->|Prompt Esaurimento Imminente| G[🛒 Lista Spesa Automatica]
    end
```

### Modelli TFLite (DistilBERT) & Scansione Scontrini

L'acquisizione dei prodotti si fonda su una pipeline ibrida ultra-ottimizzata:
1. **Google ML Kit OCR:** Cattura il testo sgranato e abbreviato tipico degli scontrini fiscali.
2. **DistilBERT (TFLite):** Un modello di intelligenza artificiale integrato on-device interpreta il significato semantico delle voci.
3. **Local Receipt Parser & Fuzzy Matching:** Il sistema confronta le voci lette con un dizionario integrato (organizzato in reparti come *Frutta & Verdura*, *Latticini*, *Secco & Pasta*, *Surgelati*). Quando riscontra stringhe troncate come *"MLK PARZ SCR 1L"*, l'algoritmo calcola il livello di similarità stringa e capisce automaticamente che si tratta di *"Latte Parzialmente Scremato"*, assegnando l'icona corretta (🥛) e stimando la durata di conservazione tipica (es. 7 giorni).

### Motore Predittivo Comportamentale (Smart Pantry AI)

L'intelligenza artificiale non si limita a catalogare, ma impara lo stile di vita della casa studiando lo storico log (`pantry_logs`):
* **Frequenza di Acquisto:** Calcola la media dei giorni che trascorrono tra un acquisto e il successivo per un determinato bene. Se i coinquilini comprano il pane ogni 3 giorni, l'algoritmo predice il momento preciso in cui la scorta sta per esaurirsi.
* **Messaggistica "Scadenza Imminente":** L'IA monitora il conto alla rovescia di freschezza. Quando mancano 0 giorni alla scadenza, un avviso mirato informa il gruppo: *"Scadenza imminente (Scade tra poche ore)"*.
* **Feedback Loop:** Il sistema impara dalle scelte degli utenti. Ogni volta che un suggerimento predittivo viene accettato o scartato, i punteggi di confidenza si aggiornano per calibrare perfettamente le future proposte sulla reale dieta abituale della casa.

---

## 📱 Esplorazione delle Funzionalità Chiave

```mermaid
flowchart TD
    subgraph Ecosistema AvanziZero
        A[📸 Fotografa lo Scontrino] -->|IA Estrae Prodotti e Scadenze| B(📦 Dispensa Smart Condivisa)
        B -->|Allarme Scadenza vicina| C{🍲 Cosa Cucino Stasera?}
        C -->|Catalogo SQLite + Web Live| D[Ricettario AvanziZero]
        D -->|Mancano 2 ingredienti?| E(🛒 Lista Spesa Sincronizzata)
        B -->|L'IA nota che sta finendo il latte| E
        E -->|Acquista nei Supermercati vicini| B
    end
```

### 1. La Dispensa Smart & Condivisa
La tua cucina digitale, sempre in tasca e perfettamente organizzata.

* **Indicatori Visivi di Freschezza:** Ogni prodotto è accompagnato da un badge dinamico colorato. Vedi a colpo d'occhio cosa è fresco (🟢), cosa va consumato a breve (🟡) e cosa è in scadenza critica (🔴).
* **Organizzazione per Categorie:** Frutta, Latticini, Carni, Lievitati, Dispensa Secca. Filtra e cerca i prodotti istantaneamente grazie alla comoda barra di navigazione orizzontale (`HorizontalHeaderMenu`).
* **Sincronizzazione in Tempo Reale:** Qualsiasi coinquilino aggiunga, modifichi o consumi un prodotto, l'intera casa vede la variazione istantaneamente in tempo reale.

---

### 2. Importazione Magica Scontrini con IA On-Device
Dimentica l'inserimento manuale. Quando torni dal supermercato, ti basta scattare una foto allo scontrino.

* **Comprensione Immediata del Testo:** L'app utilizza il modello neurale integrato sul telefono per leggere e destrutturare l'intero documento in frazioni di secondo.
* **Correzione degli Errori OCR:** Gli errori di battitura della cassa vengono automaticamente riparati dal motore di similarità.
* **Divisione e Assegnazione:** Inserisci intere spese mensili nella dispensa di gruppo in meno di 5 secondi.

---

### 3. Lista della Spesa Sincronizzata & Suggerimenti Intelligenti
Fai la spesa in perfetta coordinazione, senza dimenticare nulla o fare doppioni.

* **Lista Collaborativa Live:** Aggiungi un prodotto alla lista e i tuoi coinquilini lo vedranno comparire in tempo reale mentre sono corsia per corsia al supermercato.
* **Motore Predittivo Comportamentale:** Se il gruppo beve in media 4 litri di latte a settimana, l'app noterà l'esaurimento imminente e ti suggerirà nella lista: *"Consigliato: Latte (Esaurimento imminente, acquistato ogni ~5 giorni)"*.
* **Feedback Intelligente:** L'IA si adatta a voi. Accetta o rifiuta i suggerimenti per calibrare l'algoritmo sulle vostre reali preferenze alimentari.

---

### 4. Ricettario #AvanziZero & Il "Grandissimo Retrieve" dal Web
Il vero cuore pulsante dell'applicazione. Non dovrai mai più chiederti *"cosa mangiamo stasera?"*.

```mermaid
flowchart LR
    A[Prodotti in Scadenza in Dispensa] --> B[Algoritmo AvanziZero]
    B --> C[Retrieve Live da Fatto in casa da Benedetta]
    C --> D[Filtro Immediato: Senza Forno / Con Forno]
    D --> E[Proposta Culinaria Perfetta]
```

* **Ranking Ecologico (Salviamo la Cena):** Il sistema analizza la tua dispensa e ordina le ricette mettendo al **primo posto** i piatti che sfruttano esattamente gli ingredienti che stanno per scadere in frigo!
* **Il "Grandissimo Retrieve" da Fatto in Casa da Benedetta:** Per offrire un catalogo di altissima qualità, profondamente legato alla tradizione culinaria italiana e ricchissimo di ingredienti, l'app interroga in tempo reale l'enorme archivio di *Fatto in casa da Benedetta*. Un avanzato motore di scraping asincrono a blocchi estrae foto ad alta definizione, tempi di cottura e procedimenti formattati in modo impeccabile, passo dopo passo.
* **Modalità "Senza Forno" & Filtri Istantanei:** Sei in un monolocale senza forno o fa troppo caldo per accenderlo? Attiva l'interruttore **"Senza Forno"**. Immediatamente, sia il database locale che il live scrapper filtreranno ed escluderanno qualsiasi ricetta richieda l'uso del forno, offrendoti solo soluzioni in padella, al vapore o a real-time a freddo.
* **Generatore Casuale (Pulsante Dadi 🎲):** Cerchi ispirazione pura? Tocca i dadi per compiere una ricerca esplorativa fulminea nel web e ricevere una selezione di 50 nuove idee culinarie a rotazione!
* **Tolleranza Ingredienti & Carrello Veloce:** Ti piace una ricetta ma ti mancano 2 o 3 ingredienti? Nessun problema! L'app ti mostra esattamente cosa manca e ti offre un comodo pulsante *"Aggiungi i 2 mancanti alla Spesa"*. Con un singolo tap, gli ingredienti finiscono nella lista della spesa sincronizzata del gruppo.
* **Link Diretto alla Sorgente:** Se desideri approfondire o leggere i commenti della community web, il pulsante *"Vai al sito della ricetta"* ti catapulta istantaneamente sulla pagina ufficiale del piatto.

---

### 5. Gestione Gruppi & Coinquilini
Convivere non è mai stato così rilassante.

* **Creazione Stanze/Appartamenti:** Crea il tuo "Appartamento Via Roma 12" e invita i coinquilini tramite un semplice link o codice.
* **Ripartizione Proprietà:** Assegna gli alimenti a "Tutti" per i beni comuni (olio, sale, spezie) o al singolo utente per i prodotti personali (il latte di soia di Marco, lo yogurt proteico di Sara).
* **Notifiche di Attività:** Ricevi avvisi quando qualcuno va a fare la spesa o inserisce un nuovo scontrino.

---

### 6. Radar Supermercati Vicini
Hai bisogno di un ingrediente urgente per completare una ricetta?

* **Esplorazione Mappa Integrata:** Visualizza all'istante i supermercati, minimarket e alimentari più vicini alla tua posizione attuale.
* **Calcolo della Distanza:** Scopri gli orari e il percorso più veloce per raggiungerli senza saltare da un'app all'altra.

---

## 🌿 L'Impatto Ambientale e Sociale (#AvanziZero)

Lo spreco alimentare domestico rappresenta una delle più grandi sfide ecologiche ed economiche contemporanee. Per uno studente fuorisede o un lavoratore, gettare cibo significa perdere centinaia di euro ogni anno.

**AvanziZero** affronta il problema alla radice con un approccio gamificato ed educativo:
1. **Consapevolezza Visiva:** La barra colorata delle scadenze trasforma la gestione del frigo in un obiettivo quotidiano.
2. **Valorizzazione degli Avanzi:** Non esiste rimasuglio che non possa diventare un piatto delizioso grazie al motore di ricerca integrato.
3. **Risparmio Effettivo:** Meno cibo sprecato equivale a una lista della spesa più efficiente e a un portafoglio più sereno.

---

## 🛡️ L'Esperienza Utente: Offline-First e Privacy Totale

Abbiamo ingegnerizzato AvanziZero per essere incredibilmente snello, etico e resiliente:

* **⚡ Nessun Abbonamento Esterno (100% Token-Less):** A differenza di altre app che si appoggiano ad AI cloud costose (con API keys a pagamento), la nostra pipeline di intelligenza artificiale gira interamente sul processore del tuo smartphone.
* **🔒 Massima Privacy:** I tuoi scontrini, le tue spese e le tue abitudini alimentari non vengono vendute a inserzionisti terzi o elaborate in server remoti sconosciuti.
* **📶 Funzionamento Impeccabile Offline:** Sei al supermercato dove il telefono non prende? Nessun problema! Un elegante banner animato ti informerà del passaggio in modalità offline. L'app continuerà a operare alla massima velocità appoggiandosi a un ricco catalogo SQLite integrato, per poi sincronizzarsi in modo trasparente e silente col cloud non appena riavrai la connessione.

---

## 💻 Guida all'Installazione per Sviluppatori

Vuoi testare l'app o contribuire allo sviluppo? Ecco come configurare l'ambiente di lavoro:

1. **Requisiti di Sistema:**
   - [Flutter SDK](https://flutter.dev/) (versione stabile recente, 3.x)
   - Emulatore Android/iOS o dispositivo fisico configurato per il debug
   - Git per il controllo di versione

2. **Procedura di Build:**
   ```bash
   # 1. Clona il repository ufficiale
   git clone https://github.com/YuliaD2609/AvanziZero.git
   cd AvanziZero/flutter_app

   # 2. Ottieni le dipendenze del progetto
   flutter pub get

   # 3. Verifica l'assenza di errori di sintassi e linting
   flutter analyze

   # 4. Compila ed esegui l'app sul tuo dispositivo
   flutter run
   ```
