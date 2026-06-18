# Requirements Analysis Document (RAD)
**Progetto:** AvanziZero — Gestione Domestica Condivisa e Lista della Spesa Intelligente
**Versione:** 1.0 | **Data:** Giugno 2026

---

## 1. Introduction

### 1.1 Purpose of the system
Il sistema **AvanziZero** ha lo scopo di digitalizzare e centralizzare la gestione della vita domestica condivisa per gruppi di persone (coinquilini, studenti fuorisede, famiglie, coppie). Il sistema offre un unico ambiente collaborativo e sincronizzato in cui monitorare l'inventario della dispensa, gestire la lista della spesa, ricevere alert automatici sulle scadenze dei prodotti e ottenere suggerimenti predittivi basati sull'Intelligenza Artificiale per anticipare le necessità di riacquisto.

L'obiettivo primario è eliminare gli sprechi — sia alimentari (prodotti scaduti non rilevati) che economici (acquisti doppi per mancanza di coordinamento) — e ridurre il carico cognitivo legato alla pianificazione domestica settimanale.

### 1.2 Scope of the system
AvanziZero è un'applicazione mobile cross-platform (iOS/Android) sviluppata in Flutter/Dart. Il backend è basato su architettura cloud serverless Firebase (Firestore, Authentication, Cloud Functions). Il sistema gestisce:
- Autenticazione utenti (email/password) con recupero password via email.
- Creazione e accesso a gruppi domestici tramite codici univoci o sistema di richiesta di adesione.
- Gestione ruoli (Admin / Membro) all'interno di ogni gruppo.
- Inventario della dispensa in tempo reale, sincronizzato tra tutti i membri del gruppo.
- Lista della spesa condivisa, con spunta e trasferimento automatico in dispensa.
- Motore di IA predittiva che analizza la frequenza di consumo storica e genera suggerimenti di riacquisto.
- Scanner OCR (Optical Character Recognition) per l'inserimento rapido di prodotti tramite fotografia di scontrini.
- Ricerca di supermercati nelle vicinanze tramite geolocalizzazione.
- Impostazioni personali (nome, email, password, notifiche) e gestione del profilo.

### 1.3 Objectives and success criteria of the project
| Obiettivo | Criterio di Successo |
| :--- | :--- |
| Eliminare la frammentazione nella gestione della spesa condivisa | Il 100% delle operazioni (lista, inventario, categorie) è condiviso in real-time tra tutti i membri del gruppo |
| Ridurre lo spreco alimentare | Almeno il 70% degli utenti riceve e consulta l'alert "Prodotti in scadenza" nella Home Screen |
| Abbattere il tempo di compilazione della lista | La revisione dei suggerimenti IA richiede meno di 30 secondi per sessione |
| Aumentare l'accuratezza predittiva nel tempo | Tasso di accettazione dei suggerimenti IA > 80% dopo 4 settimane di utilizzo |
| Garantire l'esperienza collaborativa | Sincronizzazione real-time delle modifiche entro 500ms tra dispositivi |

### 1.4 Definitions, acronyms, and abbreviations
- **Pantry (Dispensa):** La sezione dell'app che digitalizza l'inventario fisico della cucina domestica.
- **Shopping List (Lista della Spesa):** La sezione che gestisce i prodotti da acquistare, condivisa tra tutti i membri del gruppo.
- **Gruppo Casa:** L'unità organizzativa dell'app, che raccoglie uno o più utenti (coinquilini/familiari) condividendo uno stesso inventario.
- **Codice Casa:** Identificativo univoco alfanumerico del gruppo (es. "CASA-7B4D"), usato per l'invito e l'accesso al gruppo.
- **Admin:** Ruolo con privilegi aggiuntivi (gestione membri, richieste di adesione, impostazioni gruppo).
- **IA / ML:** Intelligenza Artificiale / Machine Learning — il motore predittivo che genera suggerimenti per la lista della spesa.
- **OCR:** Optical Character Recognition — tecnologia che converte il testo da immagini (es. scontrini) in dati digitali.
- **Zero Spreco:** Filosofia del progetto orientata alla riduzione degli sprechi alimentari ed economici.
- **Spesa Fatta:** Azione che sposta gli articoli spuntati dalla lista della spesa direttamente in dispensa.
- **Urgency Level:** Classificazione cromatica automatica dei prodotti in dispensa in base alla data di scadenza (Verde=fresco, Giallo=in scadenza a 7 giorni, Rosso=oggi/domani/scaduto).

### 1.5 References
- Contextual Inquiry Document — AvanziZero
- Firebase Documentation (Firestore, Authentication, Cloud Functions)
- Material Design 3 Guidelines
- GDPR (Regolamento UE 2016/679)

### 1.6 Overview
Il Capitolo 2 descrive i limiti dell'ecosistema attuale di strumenti usati dagli utenti. Il Capitolo 3 modella il sistema proposto attraverso requisiti funzionali, non funzionali e modelli del sistema (scenari, Use Cases, Object Model, Dynamic Model, navigational paths). Il Capitolo 4 contiene il Glossario.

---

## 2. Current system
La gestione domestica condivisa si basa attualmente su un patchwork di strumenti non ottimizzati:
- **WhatsApp / Telegram:** usati come lista condivisa improvvisata. I messaggi si perdono nel flusso di conversazione. Nessuna struttura, nessun inventario, nessuna predizione.
- **Note generiche (Keep, Memo):** liste digitali semplici, non collaborative, prive di logica di categorizzazione o alert scadenze.
- **Carta e penna / lavagna:** massimo controllo ma zero condivisione digitale, non accessibili da remoto.
- **Memoria individuale:** il metodo più diffuso — e il meno affidabile. Causa acquisti doppi, dimenticanze e prodotti scaduti non rilevati.

Nessuno strumento attuale integra inventario, alert scadenze, collaborazione real-time e predizione IA in un'unica piattaforma dedicata.

---

## 3. Proposed system

### 3.1 Overview
AvanziZero sostituisce l'intero ecosistema frammentato con una piattaforma unificata. Il punto di rottura rispetto a qualsiasi soluzione esistente è la comunicazione bidirezionale tra le tre entità del sistema: **Dispensa ↔ Lista della Spesa ↔ Motore IA**. Quando un prodotto viene consumato (eliminato dalla dispensa), il sistema registra il dato temporale. Quando la frequenza di consumo storica raggiunge una soglia, l'IA propone il riacquisto. Quando l'utente spunta l'articolo come "Spesa Fatta", il prodotto torna in dispensa in modo automatico, chiudendo il ciclo. L'utente non deve più gestire manualmente nessuno dei passaggi intermedi.

### 3.2 Functional requirements

**Modulo 1: Autenticazione & Account**
- **FR1.1:** L'utente deve potersi registrare con email e password, con validazione della robustezza della password (min. 8 caratteri, maiuscola, minuscola, numero e carattere speciale).
- **FR1.2:** L'utente deve poter accedere con le proprie credenziali (email/password).
- **FR1.3:** L'utente deve poter recuperare la password via link inviato per email ("Hai dimenticato la password?").
- **FR1.4:** L'utente deve poter effettuare il logout, tornando alla schermata di autenticazione.
- **FR1.5:** Il sistema deve mantenere la sessione attiva tra una chiusura e la riapertura dell'app, ripristinando il contesto precedente (gruppo attivo o Home dei gruppi).

**Modulo 2: Gestione Gruppi Casa**
- **FR2.1:** L'utente autenticato deve poter creare un nuovo gruppo, generando un codice casa univoco alfanumerico (formato "CASA-XXXX").
- **FR2.2:** L'utente deve poter unirsi a un gruppo esistente inserendo il codice casa.
- **FR2.3:** Per i gruppi con sistema di richiesta di adesione, l'utente deve poter inviare una richiesta di accesso che l'Admin dovrà approvare o rifiutare.
- **FR2.4:** L'Admin deve poter accettare o rifiutare le richieste di adesione in entrata.
- **FR2.5:** L'Admin deve poter rimuovere un membro dal gruppo, previo avviso esplicito dell'irreversibilità dell'azione.
- **FR2.6:** L'Admin deve poter promuovere un membro al ruolo di Admin.
- **FR2.7:** L'Admin deve poter rinominare il gruppo.
- **FR2.8:** L'Admin deve poter eliminare definitivamente il gruppo (cancellazione di tutti i dati).
- **FR2.9:** Un utente rimosso o che accede a un gruppo eliminato deve ricevere un banner informativo esplicito.
- **FR2.10:** Il sistema deve mantenere una cronologia dei gruppi visitati per utente, separata per account.

**Modulo 3: Dispensa (Pantry)**
- **FR3.1:** L'utente deve poter visualizzare l'inventario completo della dispensa del gruppo, aggiornato in tempo reale.
- **FR3.2:** L'utente deve poter aggiungere un prodotto alla dispensa specificando: nome, quantità, data di scadenza e categoria.
- **FR3.3:** L'utente deve poter modificare i dati di un prodotto esistente in dispensa.
- **FR3.4:** L'utente deve poter eliminare un prodotto dalla dispensa.
- **FR3.5:** Il sistema deve calcolare automaticamente il livello di urgenza di ogni prodotto in base alla data di scadenza (Verde/Giallo/Rosso) e visualizzarlo cromaticamente.
- **FR3.6:** La Home Screen deve mostrare la lista dei prodotti in scadenza imminente (urgencyLevel > 0), ordinata per data.
- **FR3.7:** L'utente deve poter filtrare i prodotti per categoria tramite menu verticale a sinistra.
- **FR3.8:** L'utente deve poter cercare un prodotto tramite barra di ricerca testuale.
- **FR3.9:** L'utente deve poter aggiungere prodotti tramite scansione OCR degli scontrini (fotografia o galleria).
- **FR3.10:** L'utente deve poter vedere chi ha inserito ogni prodotto (campo ownerId).

**Modulo 4: Lista della Spesa (Shopping List)**
- **FR4.1:** L'utente deve poter visualizzare la lista della spesa condivisa del gruppo, aggiornata in tempo reale.
- **FR4.2:** L'utente deve poter aggiungere un prodotto alla lista della spesa specificando nome, quantità e categoria.
- **FR4.3:** L'utente deve poter eliminare un prodotto dalla lista della spesa.
- **FR4.4:** L'utente deve poter spuntare (selezionare) gli articoli acquistati durante la spesa fisica.
- **FR4.5:** La funzione "Spesa Fatta" deve spostare tutti gli articoli spuntati dalla lista della spesa alla dispensa, aggiornando Firestore in un'unica transazione.
- **FR4.6:** L'utente deve poter filtrare gli articoli per categoria e cercarli per nome.

**Modulo 5: Categorie Condivise**
- **FR5.1:** Le categorie di Dispensa e Lista della Spesa devono essere unificate in un'unica lista condivisa per gruppo.
- **FR5.2:** L'aggiunta di una nuova categoria deve renderla visibile a tutti i membri del gruppo in entrambe le sezioni.
- **FR5.3:** La rimozione di una categoria deve aggiornare tutti i prodotti appartenenti a quella categoria (riassegnandoli a "Altro").
- **FR5.4:** Le categorie devono essere persistite su Firestore per garantire la sincronizzazione multi-dispositivo.

**Modulo 6: IA Predittiva (Predictive Shopping)**
- **FR6.1:** Il sistema deve analizzare la frequenza storica di consumo dei prodotti per ogni gruppo.
- **FR6.2:** Il sistema deve generare proattivamente suggerimenti di riacquisto per i prodotti che, in base allo storico, dovrebbero essere prossimi all'esaurimento.
- **FR6.3:** I suggerimenti devono essere presentati come banner dismissibile nella lista della spesa.
- **FR6.4:** L'utente deve poter accettare un suggerimento (aggiungendolo alla lista) o scartarlo.
- **FR6.5:** Il sistema deve usare ogni accettazione/rifiuto come feedback per affinare il modello predittivo.

**Modulo 7: Supermercati nelle Vicinanze**
- **FR7.1:** Il sistema deve recuperare e mostrare i supermercati più vicini all'utente tramite API di geolocalizzazione.
- **FR7.2:** Per ogni supermercato deve essere mostrato nome, distanza (km) e indirizzo.
- **FR7.3:** L'utente deve poter aprire il percorso verso un supermercato direttamente nell'app mappe del dispositivo.

**Modulo 8: Profilo & Impostazioni**
- **FR8.1:** L'utente deve poter modificare il proprio nome e password dall'Area Profilo.
- **FR8.2:** L'utente deve poter configurare la ricezione delle notifiche e l'orario dei promemoria giornalieri.
- **FR8.3:** L'utente deve poter effettuare il logout dal profilo, con ritorno alla schermata di autenticazione.

### 3.3 Nonfunctional requirements

#### 3.3.1 Usability
- L'interfaccia deve essere utilizzabile con una sola mano (*One-Handed Operation*), specialmente nelle schermate della lista della spesa usate al supermercato.
- L'aggiunta di un prodotto (dispensa o lista) deve richiedere al massimo 3 interazioni (tap).
- Ogni azione distruttiva (rimozione membro, eliminazione gruppo) deve essere preceduta da un dialog di conferma esplicito con avviso di irreversibilità.
- Il font di sistema è **Outfit** per garantire leggibilità e coerenza visiva.

#### 3.3.2 Reliability
- Il sistema Firestore deve garantire il **99.9% di uptime** per le operazioni CRUD.
- In caso di assenza di rete (es. al supermercato), l'app deve operare in modalità **Offline-First**, usando la cache locale (SharedPreferences) e sincronizzando con Firestore al ripristino della connessione.
- Un membro rimosso o un gruppo eliminato deve essere rilevato dal listener Firestore entro 2 secondi, propagando l'avviso a tutti i dispositivi connessi.

#### 3.3.3 Performance
- La sincronizzazione real-time di un'operazione CRUD su Firestore deve riflettersi nell'UI degli altri dispositivi entro **500ms**.
- L'elaborazione OCR di uno scontrino deve completarsi entro **3 secondi**.
- La generazione dei suggerimenti IA deve avvenire entro **1 secondo** dall'apertura della schermata Lista della Spesa.
- Il calcolo del livello di urgenza (urgencyLevel) dei prodotti deve essere eseguito lato client senza bloccare il thread principale dell'UI.

#### 3.3.4 Supportability
- Il codice deve seguire il pattern **Provider / ChangeNotifier** (AppState come Single Source of Truth) per facilitare il mantenimento e l'onboarding di nuovi sviluppatori.
- Le operazioni Firebase devono essere incapsulate nel layer `FirebaseService` per isolare la logica di business dall'interfaccia.

#### 3.3.5 Implementation
- **Frontend:** Flutter 3.x / Dart 3.x (cross-platform iOS e Android da un unico codebase).
- **Backend:** Firebase Firestore (database NoSQL real-time), Firebase Authentication (gestione utenti), Firebase Cloud Functions (logica serverless).
- **IA:** API Google Generative AI (`google_generative_ai` SDK) per l'analisi predittiva e l'OCR.
- **Geolocalizzazione:** `geolocator` package + API Places.

#### 3.3.6 Interface
- Palette cromatica: "Pastel Sage & Soft Mint" (Verde Salvia #6B9E7A come colore primario, Avorio #F5F0E8 come sfondo).
- Componenti *card-based* con bordi arrotondati (BorderRadius 20px) e ombre leggere per la profondità.
- Color-coding automatico per le scadenze: 🟢 Verde (>7 giorni), 🟡 Giallo (2-7 giorni), 🔴 Rosso (0-1 giorno o scaduto).
- Bottom Navigation Bar con 3 tab principali: Home, Dispensa, Lista della Spesa.

#### 3.3.7 Packaging
- L'applicazione deve pesare meno di **50MB** per agevolare il download in mobilità.
- Distribuita tramite **Google Play Store** (Android) e **Apple App Store** (iOS).

#### 3.3.8 Legal
- Il trattamento dei dati personali (email, abitudini di consumo, dati di gruppo) è soggetto al **GDPR (Reg. UE 2016/679)**.
- I dati alimentari e di consumo analizzati dall'IA rimangono associati al singolo gruppo e non vengono ceduti a terze parti.
- L'utente deve fornire il consenso esplicito al trattamento dei dati al primo accesso.
- La cancellazione definitiva del gruppo comporta il **wipe completo** di tutti i dati su Firestore (subcollection items, richieste, documento principale).

### 3.4 System models

#### 3.4.1 Scenarios

**Scenario A: Onboarding e Primo Gruppo**
Giulia apre AvanziZero per la prima volta. Si registra con email e password. Viene portata alla schermata "Gruppi": non ha ancora nessun gruppo. Crea un nuovo gruppo: il sistema genera il codice "CASA-4K8J". Lo condivide su WhatsApp con i suoi 3 coinquilini. Loro aprono l'app, si registrano, inseriscono il codice e inviano la richiesta di adesione. Giulia, da Admin, vede le richieste in arrivo e le approva. In 5 minuti, tutti e quattro sono all'interno dello stesso inventario condiviso.

**Scenario B: Gestione Quotidiana della Dispensa**
Marco finisce il latte. Apre AvanziZero, va in Dispensa, cerca "Latte" e lo elimina. Contemporaneamente, la sua coinquilina vede l'inventario aggiornarsi in tempo reale sul suo dispositivo. L'IA registra l'evento. Nota che il latte viene acquistato ogni 5 giorni circa. Dopo 4 giorni, nella Lista della Spesa compare il banner "Predictive Shopping: potrebbe servirti il Latte".

**Scenario C: La Spesa al Supermercato**
Elena è al supermercato con l'app aperta sulla Lista della Spesa. Spunta gli articoli man mano che li inserisce nel carrello. Tornata a casa, preme "Spesa Fatta": tutti gli articoli selezionati spariscono dalla lista e compaiono automaticamente in Dispensa. Non deve fare nulla manualmente.

**Scenario D: Alert Scadenza**
Aprendo la Home Screen, Giovanni vede nella sezione "Prodotti in scadenza" che lo yogurt greco scade domani e la mozzarella oggi. I nomi appaiono in rosso. Decide di consumarli per cena invece di ordinarsi la pizza.

#### 3.4.2 Use case model

**Attore: Utente Non Autenticato**
- UC1: Registrazione con email/password
- UC2: Login con email/password
- UC3: Recupero password via email

**Attore: Utente Membro**
- UC4: Creare/Unirsi a un gruppo casa
- UC5: Visualizzare la Dispensa
- UC6: Aggiungere/Modificare/Eliminare prodotti in Dispensa
- UC7: Scansionare uno scontrino via OCR
- UC8: Visualizzare la Lista della Spesa
- UC9: Aggiungere/Eliminare articoli dalla Lista della Spesa
- UC10: Spuntare articoli acquistati → "Spesa Fatta"
- UC11: Aggiungere/Rimuovere categorie condivise
- UC12: Visualizzare supermercati nelle vicinanze
- UC13: Modificare profilo personale (nome, password, notifiche)
- UC14: Uscire dal gruppo (temporaneamente)
- UC15: Logout dall'account

**Attore: Utente Admin** (estende i permessi del Membro)
- UC16: Accettare/Rifiutare richieste di adesione al gruppo
- UC17: Rimuovere un membro dal gruppo
- UC18: Promuovere un membro ad Admin
- UC19: Rinominare il gruppo
- UC20: Eliminare definitivamente il gruppo

**Attore: Sistema IA**
- UC21: Analisi frequenza di consumo storica
- UC22: Generazione suggerimenti predittivi per la Lista della Spesa
- UC23: Aggiornamento del modello predittivo tramite feedback utente

#### 3.4.3 Object model

```
User
  - id: String (uid Firebase)
  - email: String
  - name: String
  - groupIds: List<String>
  - pendingGroupIds: List<String>

Group
  - id: String (es. "CASA-7B4D")
  - name: String?
  - members: List<String> (uids)
  - adminIds: List<String> (uids)
  - categories: List<String> (condivise tra Dispensa e Lista)

Item
  - id: String
  - name: String
  - quantity: int
  - category: String
  - expireDate: String (formato gg/mm/aaaa o "-")
  - isPantry: bool
  - isShopping: bool
  - ownerId: String? (uid di chi ha inserito il prodotto)

ItemModel (lato client)
  - urgencyLevel: int (0=verde, 1=giallo, 2=rosso) [calcolato da expireDate]
  - parsedExpireDate: DateTime? [calcolato da expireDate]

SupermarketModel
  - name: String
  - distance: String
  - address: String
```

#### 3.4.4 Dynamic model

**Ciclo di vita di un Prodotto:**

```
[Creato in Lista Spesa]
       │
       ▼
[Spuntato (Acquistato)]
       │
       ▼ "Spesa Fatta"
[Creato in Dispensa]
       │
       ├─── urgencyLevel = 0 → 🟢 Verde (fresco)
       ├─── urgencyLevel = 1 → 🟡 Giallo (scade in 2-7 giorni)
       └─── urgencyLevel = 2 → 🔴 Rosso (oggi/domani/già scaduto)
       │
       ▼ [Eliminato / Consumato]
[ConsumptionEvent registrato dall'IA]
       │
       ▼ [IA analizza frequenza]
[Suggerimento generato in Lista Spesa]
       │
       ├─── Accettato → torna in Lista Spesa → ciclo ricomincia
       └─── Rifiutato → modello IA aggiornato (frequenza rivista)
```

**Ciclo di vita di un Gruppo:**

```
[Creato dall'Admin con codice univoco]
       │
       ├─── Membro si unisce tramite codice → entra nel gruppo
       ├─── Membro invia richiesta → Admin approva/rifiuta
       ├─── Admin rimuove membro → banner "Sei stato rimosso"
       └─── Admin elimina gruppo → banner "Gruppo eliminato" per tutti
```

#### 3.4.5 User interface — navigational paths and screen mock-ups

**Navigational Map:**

```
[Splash Screen]
       │
       ▼
[Auth Screen]  ←── "Hai dimenticato la password?" → [Password Reset Dialog]
       │ (login/registrazione)
       ▼
[Group Setup Screen]  ←── Nessun gruppo attivo
       │  (crea o unisciti a un gruppo)
       ▼
[Main Navigator - Bottom Navigation Bar]
       ├── Tab 0: [Home Screen]
       │          ├── Banner Gruppo Attivo + Codice Casa
       │          ├── Bottone → Lista della Spesa
       │          ├── Bottone → Dispensa
       │          └── Widget "Prodotti in scadenza" (alert cromatico)
       │
       ├── Tab 1: [Pantry Screen (Dispensa)]
       │          ├── Header con icona Supermercati (→ Bottom Sheet)
       │          ├── Menu Categorie verticale (sx)
       │          ├── Barra di Ricerca
       │          ├── Lista prodotti (card con urgencyLevel colorato)
       │          ├── FAB "Aggiungi prodotto" → Dialog inserimento
       │          └── Bottone OCR → [OCR Scanner Modal]
       │
       └── Tab 2: [Shopping Screen (Lista Spesa)]
                  ├── Menu Categorie verticale (sx)
                  ├── Barra di Ricerca
                  ├── Banner "Predictive Shopping" (dismissibile)
                  ├── Lista articoli con checkbox
                  ├── Pulsante "Spesa Fatta"
                  └── Pulsante "Aggiungi un elemento" → Dialog inserimento

[Admin Screen] ← accessibile da icona profilo in Home/Dispensa/Spesa
       ├── Sezione: I Miei Dati Personali (nome, email, password)
       ├── Sezione: Impostazioni Notifiche (toggle + orario)
       ├── Pulsante: Esci dal Profilo (Logout)
       ├── [Solo se gruppo attivo]:
       │   ├── Sezione: Nome del Gruppo (modifica)
       │   ├── Sezione: Membri del Gruppo (lista, promozione Admin, rimozione)
       │   ├── Sezione: Richieste in attesa (accetta/rifiuta)
       │   ├── Pulsante: Esci dal Gruppo
       │   └── Pulsante: Elimina il Gruppo (solo Admin)
       └── [AdminScreen accessibile da tutti i Tab]
```

---

## 4. Glossary

| Termine | Definizione |
| :--- | :--- |
| **AvanziZero** | Nome del prodotto. Evoca la filosofia "zero sprechi" (avanzi = prodotti che avanzano) e la completezza del sistema (dalla A alla Z). |
| **Codice Casa** | Identificativo univoco del gruppo domestico, formato "CASA-XXXX", usato per invitare nuovi membri. |
| **Cold-Start Problem** | La difficoltà dell'IA nel fare previsioni accurate per utenti nuovi che non hanno ancora accumulato dati storici sufficienti. Mitigato dall'OCR per il popolamento rapido della dispensa. |
| **Dispensa (Pantry)** | Sezione dell'app che replica digitalmente il contenuto fisico della cucina: frigorifero, stipetti, dispensa. |
| **Offline-First** | Paradigma architetturale in cui le funzionalità principali (consultazione lista, visualizzazione dispensa) restano operative anche senza connessione internet, sincronizzandosi alla riconnessione. |
| **Spesa Fatta** | Azione che trasferisce automaticamente gli articoli spuntati dalla Lista della Spesa alla Dispensa, chiudendo il ciclo di acquisto. |
| **Urgency Level** | Livello di urgenza calcolato automaticamente dal sistema per ogni prodotto in Dispensa sulla base della sua data di scadenza. 0 = Verde (ok), 1 = Giallo (entro 7 giorni), 2 = Rosso (entro 1 giorno o già scaduto). |
| **Wipe del Gruppo** | Eliminazione definitiva e irreversibile di tutti i dati di un gruppo da Firestore (inventario, lista, categorie, richieste). |
