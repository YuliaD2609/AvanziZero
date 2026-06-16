# FarFromHome - Registro dei Task e Responsabilità di Progetto

Questo documento definisce formalmente la suddivisione delle responsabilità all'interno del team per il progetto **FarFromHome**, distinguendo i compiti del Frontend/Firebase (Serverless Full-Stack) da quelli del Backend/IA. 

Contiene lo stato attuale dell'applicazione (compiti completati) e i prossimi passaggi necessari prima della consegna.

---

## 📊 Tabella delle Responsabilità (Canvas & Feature)

| Modulo Canvas / Feature | 🔥 Task Tuoi (Frontend Flutter + Firebase) | 🧠 Task Altra Persona (Servizi IA, Logica & CRON) |
| :--- | :--- | :--- |
| **Database & Auth** | Setup Firestore, modellazione NoSQL, Firebase Auth, Security Rules. | Nessuno (utilizza le tue collezioni tramite Admin SDK). |
| **House Sync (Coinquilini)** | Sincronizzazione UI con `StreamBuilder`, gestione inviti/join casa. | Algoritmo matematico a grafi per la **semplificazione dei debiti** (stile Splitwise). |
| **IA Scanning (Scontrini)** | Scatto foto (Camera API), upload immagine su Firebase Storage/API. | Servizio OCR + parsing LLM per estrarre prodotti e scriverli pre-categorizzati sul DB. |
| **Predictive Shopping** | UI/UX lista predittiva, ascolto reattivo dei prodotti suggeriti. | Algoritmo di ML/Data Mining in background sullo storico consumi per prevedere l'esaurimento. |
| **Zero Spreco (Scadenze)**| Permessi OS, gestione ricezione notifica e navigazione (deep link). | CRON Job/Cloud Scheduler che gira ogni notte, trova scadenze e spara notifiche (FCM). |
| **Mappe & Supermercati** | Lettura coordinate GPS correnti, rendering Mappa e marker nativi. | Microservizio Proxy per interrogare Google Places/GDO, calcolare sconti e filtrare vicini. |
| **Monetizzazione (Freemium)**| UI Paywall, acquisti IAP/RevenueCat, blocco UI base. | Logica server-side di decremento e reset mensile delle quote gratuite di IA Scanning. |

---

## 🛠 Registro Stato Avanzamento Task

### 1. 🔥 Task Tuoi (Frontend Flutter + Firebase)

#### A. Sviluppo UI e Layout (Completato)
- [x] **UI Alta Fedeltà:** Interfaccia utente implementata per Home, Dispensa (Zero Spreco), Lista della Spesa e Scansione Scontrino.
- [x] **Style Guide & Coerenza:** Implementazione dei token cromatici (Pastel Sage & Soft Mint) e dei font (*Outfit*).
- [x] **Prevenzione Bug Grafici:** Ottimizzazione del modale supermercati (scorrimento e prevenzione bottom overflow).

#### B. Setup Firebase e Modellazione NoSQL (In Corso)
- [x] **Firebase Core Setup:** Collegamento del framework all'avvio dell'app in `main.dart`.
- [x] **Struttura Database Firestore:** Configurazione iniziale di letture e scritture basate su collezioni Firestore.
- [ ] **Configurazione Console:** Registrazione delle app su console Firebase per Android/iOS e download dei file di configurazione (`google-services.json`).
- [ ] **Modellazione dei Dati NoSQL definitiva:**
  - `households/{houseId}` (dati generali della casa)
  - `households/{houseId}/pantry_items/{itemId}` (dispensa)
  - `households/{houseId}/shopping_list/{itemId}` (lista spesa)
  - `households/{houseId}/expenses/{expenseId}` (spese coinquilini)
- [ ] **Firebase Security Rules:** Scrittura delle regole di accesso per consentire la lettura/scrittura solo agli utenti appartenenti alla stessa casa.

#### C. Autenticazione e Gestione Stato (Da Fare)
- [ ] **Firebase Auth:** Sviluppo della schermata di registrazione e login (Email/Password).
- [ ] **Mappatura Utente:** Associazione dell'UID dell'utente autenticato al rispettivo `houseId` (Codice Casa) in Firestore.
- [ ] **Refactoring State Management (Sincronizzazione in tempo reale):** Raccordo completo tra `AppState` e gli stream di Firestore (`snapshots()`) per propagare le modifiche istantanee tra i telefoni dei coinquilini.

#### D. Hardware Fotocamera e Storage (IA Scanning) (In Corso)
- [x] **Integrazione Fotocamera Nativa:** Utilizzo di `image_picker` per acquisire la foto dello scontrino o sceglierla dalla galleria (completato in `ocr_scanner_modal.dart`).
- [ ] **Upload a Storage:** Caricamento delle immagini su Firebase Storage per renderle accessibili al backend OCR.
- [ ] **UI di Validazione/Revisione:** Interfaccia per mostrare all'utente i prodotti estratti dall'IA, consentendogli di correggerli prima di salvarli su Firestore.

#### E. GPS, Mappe, Notifiche e Paywall (Da Fare)
- [ ] **Geolocalizzazione & Google Maps:** Lettura coordinate GPS correnti tramite `geolocator` e rendering dei pin nativi dei supermercati vicini usando `google_maps_flutter`.
- [ ] **Client Firebase Cloud Messaging (FCM):** Configurazione dei permessi di notifica nativi e gestione dei deep link per atterrare sulla Dispensa in caso di alert cibo in scadenza.
- [ ] **Monetizzazione & Paywall:** Disegno dell'interfaccia Paywall per gli utenti base e blocco delle funzionalità Premium (es. scansione illimitata) se il flag `isPremium` è falso su Firestore.

---

### 2. 🧠 Task Altra Persona (Servizi IA, Logica & Background)

#### A. Microservizio OCR & LLM per Scontrini (Da Fare)
- [ ] **Trascrizione OCR:** Endpoint per ricevere le foto degli scontrini ed estrarre il testo tramite Google Cloud Vision o simili.
- [ ] **Classificazione Intelligente (LLM):** Parsing del testo estratto tramite API (es. Gemini) per individuare nome prodotto, prezzo e categoria e mapparli sui tag dell'app.
- [ ] **Iniezione Dati su Firestore:** Scrittura diretta dei prodotti estratti nella collezione temporanea della casa usando il **Firebase Admin SDK**.

#### B. Motore Predittivo dei Consumi (Da Fare)
- [ ] **Data Mining Storico:** Analisi in background dei tempi di aggiunta/consumo per ciascun articolo e casa.
- [ ] **Predizione Esaurimento:** Calcolo dei tempi medi di consumo e iniezione automatica dell'articolo nella lista della spesa con flag `isAiSuggested: true`.

#### C. Semplificazione del Debito Coinquilini (Da Fare)
- [ ] **Algoritmo a Grafi:** Calcolo periodico dei debiti incrociati e semplificazione delle transazioni (stile Splitwise) per minimizzare i rimborsi.
- [ ] **Aggiornamento Saldi:** Aggiornamento dei saldi finali sul documento della casa in Firestore.

#### D. Schedulazione Notifiche (Zero Spreco) & Proxy Mappe (Da Fare)
- [ ] **CRON Job Scadenze:** Script giornaliero in background che interroga Firestore, rileva cibi in scadenza entro 48 ore e invia notifiche tramite Firebase Cloud Messaging.
- [ ] **Proxy Mappe Sicuro:** Endpoint API che funge da proxy per Google Places, proteggendo la chiave API ed esponendo all'app solo i supermercati vicini.
- [ ] **Quota Checker Freemium:** Controllo del limite mensile di scansioni scontrini per gli utenti non Premium e decremento quota.

---

## 🎓 Deliverable Accademici & Esame

### 1. Documentazione Formale (Da Fare)
- [ ] **Requirements Analysis Document (RAD):** Scrivere la relazione basata su Bruegge-Dutoit, includendo requisiti funzionali/non funzionali, casi d'uso dettagliati, diagramma delle classi di analisi e diagramma di sequenza della sincronizzazione e scansione OCR.
- [ ] **Business Model Canvas (BMC):** Relazione esplicativa sui 9 blocchi, con focus sul modello Freemium basato sui limiti server-side impostati dal backend del collega.
- [ ] **Pitch Presentation:** Redazione delle slide per presentare il progetto (problema, soluzione, BMC, architettura, demo, team).

### 2. Packaging e Consegna (Da Fare)
- [ ] **Codice e README_DEV:** Inserire i nomi di tutti i membri nel codice e redigere una guida di avvio pulita.
- [ ] **Archivio ZIP:** Pulizia dei file di build e creazione dello zip finale da inviare a `snocera@unisa.it` 4 giorni prima dell'esame.
- [ ] **Live Demo & Test:** Installazione dell'APK su smartphone fisico per la prova pratica davanti al docente.
