# Requirements Analysis Document (RAD)
**Progetto:** AvanziZero - Gestione Intelligente della Dispensa e Lista della Spesa Predittiva
**Versione:** 1.0
**Autore:** Team AvanziZero

---

## 1. Introduction

### 1.1 Purpose of the system
Il sistema "AvanziZero" ha lo scopo di rivoluzionare la gestione dell'inventario domestico e l'organizzazione della spesa per gruppi di individui (studenti fuorisede, coinquilini, famiglie). Il sistema mira a digitalizzare la dispensa e automatizzare la stesura della lista della spesa attraverso l'implementazione di un algoritmo di Intelligenza Artificiale (Machine Learning) in grado di apprendere le abitudini di consumo degli utenti e predire autonomamente quali prodotti necessitano di essere riacquistati.

### 1.2 Scope of the system
Il sistema consiste in un'applicazione mobile cross-platform (iOS/Android) supportata da un'architettura cloud serverless. L'app gestisce l'autenticazione, la creazione di gruppi domestici, l'inventario in tempo reale (Pantry) e la lista della spesa (Shopping List). L'engine di IA opera in background, analizzando la frequenza di consumo, l'inserimento storico e la composizione del nucleo abitativo per generare suggerimenti proattivi direttamente nell'interfaccia utente.

### 1.3 Objectives and success criteria of the project
- **Obiettivo 1:** Ridurre lo spreco alimentare (*Food Waste*) del 30% prevenendo acquisti doppi o scaduti.
- **Obiettivo 2:** Minimizzare il tempo speso per l'inventario settimanale, abbattendo il *cognitive load* dell'utente.
- **Criterio di Successo:** Il 70% degli acquisti ricorrenti viene predetto correttamente dall'IA entro il primo mese di utilizzo; un tasso di accettazione (*Acceptance Rate*) dei suggerimenti dell'IA superiore all'80%.

### 1.4 Definitions, acronyms, and abbreviations
- **IA / ML:** Intelligenza Artificiale / Machine Learning.
- **Fuorisede:** Studente universitario che vive lontano dalla città d'origine.
- **Pantry:** La dispensa fisica digitalizzata nell'app.
- **Zero-UI:** Paradigma di design in cui il sistema apprende passivamente senza richiedere input diretti o configurazioni complesse all'utente.
- **OCR:** Optical Character Recognition (usato per scansionare scontrini o codici a barre).

### 1.5 References
- Contextual Inquiry Document (AvanziZero)
- Documentazione Firebase Firestore & Authentication

### 1.6 Overview
Questo documento definisce i requisiti funzionali e non funzionali di AvanziZero. Il Capitolo 2 descrive i limiti del sistema attuale, mentre il Capitolo 3 modella il sistema proposto attraverso requisiti dettagliati, scenari e diagrammi testuali.

---

## 2. Current system
Attualmente, la gestione della spesa condivisa non si basa su un "sistema" centralizzato, ma su un patchwork di strumenti analogici e digitali non ottimizzati:
- **Comunicazione asincrona e caotica:** Gli utenti usano gruppi WhatsApp per segnalare i prodotti esauriti. I messaggi si perdono e portano ad acquisti duplicati.
- **Inventario basato sulla memoria:** L'utente controlla fisicamente la dispensa prima di uscire o, peggio, cerca di ricordare cosa manca mentre è già al supermercato. Questo comporta il rischio di dimenticare beni di prima necessità (es. olio, sale).
- **Mancanza di predizione:** Nessuno degli strumenti attuali (carta, app to-do) impara dallo storico. L'utente deve ricreare la lista manualmente ogni settimana.

---

## 3. Proposed system

### 3.1 Overview
AvanziZero rimpiazza l'approccio manuale offrendo un unico ecosistema condiviso in cui la dispensa e la lista della spesa sono entità comunicanti. L'elemento di rottura è l'assistente IA: ogni qualvolta un utente consuma un prodotto o completa un acquisto, l'algoritmo raccoglie i dati temporali. Nel tempo, l'app notificherà proattivamente gli utenti ("Sembra che il latte stia per finire") creando liste precompilate pronte per l'approvazione, eliminando totalmente la necessità di fare inventario.

### 3.2 Functional requirements
- **FR1 (Autenticazione & Gruppi):** L'utente deve potersi registrare, creare un gruppo casa o inviare/accettare inviti per unirsi a gruppi esistenti.
- **FR2 (Gestione Inventario):** L'utente deve poter inserire, modificare e rimuovere prodotti nella Dispensa (Pantry) e nella Lista della Spesa.
- **FR3 (Sincronizzazione Real-Time):** Le azioni eseguite da un membro devono riflettersi istantaneamente sui dispositivi degli altri membri del gruppo.
- **FR4 (Suggerimenti IA):** Il sistema deve analizzare lo storico del gruppo e generare una lista di prodotti suggeriti da aggiungere alla lista della spesa.
- **FR5 (Feedback Loop IA):** L'utente deve poter accettare o scartare un suggerimento dell'IA. Il sistema deve usare questa azione per aggiornare i pesi dell'algoritmo predittivo.
- **FR6 (Scanner OCR):** Il sistema deve permettere il caricamento rapido dei prodotti tramite OCR per ridurre il *cold-start problem*.

### 3.3 Nonfunctional requirements

#### 3.3.1 Usability
Il sistema adotterà un approccio *One-Handed Operation* per facilitare l'uso durante la spesa. L'accettazione di un suggerimento IA deve avvenire con massimo 1 tap (es. *Swipe to Add*). L'interfaccia deve seguire le Human Interface Guidelines e il Material Design.

#### 3.3.2 Reliability
Il sistema cloud deve garantire il 99.9% di uptime. In caso di perdita di connessione all'interno di un supermercato, l'app deve funzionare in modalità *Offline-First*, memorizzando i dati in cache locale (es. SharedPreferences/SQLite) e sincronizzandoli non appena la connessione viene ripristinata.

#### 3.3.3 Performance
- La sincronizzazione in tempo reale di un nuovo item deve avvenire in meno di 500ms.
- Il calcolo predittivo dell'IA deve restituire i risultati all'apertura della schermata in meno di 1 secondo, evitando blocchi del thread principale dell'UI.

#### 3.3.4 Supportability
L'architettura del codice dovrà seguire pattern consolidati (es. Model-View-ViewModel o Provider/State Management) per permettere un rapido onboarding di nuovi sviluppatori e facilitare i futuri aggiornamenti.

#### 3.3.5 Implementation
Il frontend sarà sviluppato in **Flutter/Dart** per garantire compatibilità nativa iOS e Android con un solo codebase. Il backend utilizzerà i servizi **Firebase** (Firestore, Auth, Cloud Functions) e l'ecosistema ML di Google per l'algoritmo predittivo.

#### 3.3.6 Interface
L'interfaccia si baserà su componenti *card-based* per i prodotti, con un chiaro *color coding* (es. verde per i prodotti abbondanti, rosso/arancione per i prodotti suggeriti dall'IA in esaurimento). Le schermate principali saranno navigabili tramite una Bottom Navigation Bar.

#### 3.3.7 Packaging
L'applicazione dovrà pesare meno di 50MB per facilitarne il download in mobilità (connessioni 4G/5G). Sarà distribuita tramite Google Play Store e Apple App Store.

#### 3.3.8 Legal
L'applicazione tratterà dati sulle abitudini di consumo alimentare. Il sistema dovrà essere conforme al **GDPR**, garantendo l'anonimizzazione dei dati passati ai modelli di ML. Gli utenti dovranno firmare una Privacy Policy chiara riguardante l'uso dei dati per scopi predittivi.

### 3.4 System models

#### 3.4.1 Scenarios
**Scenario: La spesa proattiva**
Marco è in università e decide che al ritorno passerà dal supermercato. Apre l'app AvanziZero. L'app ha calcolato che, statisticamente, l'olio d'oliva e la carta igienica del suo appartamento (3 persone) dovrebbero essere terminati. Nella schermata Home compare la card *"Suggeriti dall'IA"*. Marco seleziona "Aggiungi Entrambi" con un singolo tap e si reca al supermercato con una lista già ottimizzata.

#### 3.4.2 Use case model
- **Attore:** Utente Membro
  - *UC1:* Visualizzare Dispensa
  - *UC2:* Visualizzare e Spuntare Lista della Spesa
  - *UC3:* Approvare Suggerimento IA
- **Attore:** Utente Admin
  - *UC4:* Accettare nuovi membri nel gruppo
  - *UC5:* Rimuovere membri
- **Attore:** Sistema Cloud (IA)
  - *UC6:* Calcolo Frequenza di Consumo
  - *UC7:* Generazione Notifiche Predittive

#### 3.4.3 Object model
- **User:** `uid`, `name`, `email`, `List<String> groupIds`
- **Group:** `id`, `name`, `List<String> memberIds`, `List<String> adminIds`, `List<String> categories`
- **Item:** `id`, `name`, `quantity`, `category`, `expireDate`, `isPantry`, `isShopping`
- **ConsumptionLog:** `itemId`, `consumedDate`, `durationDays` (usato dall'IA)

#### 3.4.4 Dynamic model
**Ciclo di vita di un Prodotto (State Machine):**
1. **Stato "In Dispensa":** L'utente acquista il "Latte" e lo sposta in dispensa.
2. **Stato "Consumato":** Il latte finisce, l'utente lo cancella dalla dispensa. Il sistema registra la durata (es. 4 giorni).
3. **Stato "Analisi IA":** L'IA calcola la media mobile dei consumi del latte per quel gruppo.
4. **Stato "Suggerito":** Il sistema prevede che il latte stia finendo in base al pattern e lo mostra come *Suggerimento*.
5. **Stato "Nella Lista della Spesa":** L'utente approva il suggerimento. L'Item passa nella lista della spesa.

#### 3.4.5 User interface—navigational paths and screen mock-ups
**Navigational Path:**
`Splash Screen` -> `Auth Screen` -> `Home Screen (Dashboard & IA Suggestions)`
Dalla Home:
- `Tab 1` -> `Pantry Screen` (Lista visuale inventario)
- `Tab 2` -> `Shopping Screen` (Lista della spesa interattiva)
- `Action Button` -> `Scanner OCR` (Caricamento rapido scontrino)

---

## 4. Glossary
- **Cold-Start Problem:** La difficoltà di un'intelligenza artificiale nel fare previsioni accurate su un utente nuovo che non ha ancora fornito abbastanza dati storici.
- **Double Purchasing:** Acquisto accidentale dello stesso bene da parte di due coinquilini diversi per mancanza di comunicazione.
- **Offline-First:** Architettura software in cui le funzionalità principali sono progettate per lavorare in assenza di rete, sincronizzando i dati con il cloud solo in differita.
- **Swipe to Add:** Gesto tipico delle interfacce mobile in cui trascinando un elemento lateralmente si innesca un'azione (es. spostare un suggerimento dell'IA direttamente nella lista della spesa).
