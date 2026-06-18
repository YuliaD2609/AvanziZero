# Contextual Inquiry — AvanziZero
**Versione:** 1.0 | **Data:** Giugno 2026

---

## 1. Introduzione al progetto

**AvanziZero** è un'applicazione mobile cross-platform (Flutter/Dart) pensata per gruppi domestici condivisi: coinquilini, studenti fuorisede, coppie e famiglie. La sua missione è centralizzare e semplificare la gestione della vita domestica eliminando le inefficienze tipiche del quotidiano: prodotti scaduti non rilevati, liste della spesa dimenticate su WhatsApp, acquisti doppi per mancanza di comunicazione tra coinquilini e inventari mentali inaffidabili.

L'app si articola attorno a quattro macro-funzionalità:
1. **Autenticazione & Gestione Gruppi Casa:** registrazione, creazione di un gruppo con codice univoco, accesso a un gruppo esistente via codice condiviso, sistema di richieste di adesione, ruoli Admin/Membro.
2. **Dispensa Digitale (Pantry):** inventario della dispensa in tempo reale, condiviso tra tutti i membri del gruppo, con scansione OCR degli scontrini, filtri per categoria, barra di ricerca e alert cromatico per le scadenze.
3. **Lista della Spesa (Shopping List):** lista digitale condivisa tra i coinquilini, filtrabile per categoria, con spunta degli elementi acquistati e trasferimento automatico ("Spesa Fatta") in dispensa.
4. **IA Predittiva (Predictive Shopping):** algoritmo basato su Machine Learning che analizza la frequenza di consumo storica del gruppo per suggerire proattivamente i prodotti da riacquistare.

Queste funzionalità convergono in un ecosistema digitale che riduce al minimo l'effort manuale dell'utente e azzerano il rischio di spreco alimentare.

---

## 2. Problem scenario

### Scenario 1: La spesa parallela
**Attore:** Sofia, 23 anni, studentessa Erasmus. Condivide un appartamento con altri tre coinquilini. Nessuno dei quattro ha incarichi fissi sulla spesa.

**Scenario:** È giovedì sera. Sofia e il suo coinquilino Luca, senza saperlo, vanno entrambi al supermercato nello stesso pomeriggio. Non esiste un sistema condiviso: ognuno ricorda a modo suo cosa manca. Il risultato: tornano a casa con due confezioni di latte, due pacchi di pasta e zero carta igienica. La settimana successiva trovano nel frigo due vaschette di yogurt scaduti che nessuno ha consumato in tempo perché erano nascosti dietro altri prodotti. Nessuno sapeva fossero lì, la dispensa non è mai stata monitorata sistematicamente.

**Claims Scenario 1**
| Situation Features | Pros(+) e Cons(-) |
| :--- | :--- |
| Spesa individuale senza lista condivisa, affidata alla memoria | **+** Nessuna dipendenza da strumenti digitali.<br>**-** Alta probabilità di acquisti doppi (spreco economico).<br>**-** Nessun monitoraggio delle scadenze → spreco alimentare.<br>**-** Impossibilità di coordinarsi in tempo reale a distanza. |

### Scenario 2: La dispensa cieca
**Attore:** Marco, 29 anni, lavoratore a tempo pieno. Vive con la compagna. È lui che fa solitamente la spesa nel weekend.

**Scenario:** Marco è al supermercato il sabato mattina. Non ricorda esattamente cosa c'è in casa. Compra istintivamente quello che gli sembra possa mancare. Tornato a casa, scopre che il formaggio grana che ha appena acquistato era già in frigo in abbondanza, mentre è finito l'olio d'oliva. Lo stesso problema si ripete ogni settimana: senza un inventario digitale della dispensa, la spesa è un atto di fede nella memoria a breve termine. La sua compagna ha già segnato "olio" su un post-it appiccicato al frigo, ma Marco non lo ha visto perché è uscito presto.

**Claims Scenario 2**
| Situation Features | Pros(+) e Cons(-) |
| :--- | :--- |
| Post-it fisici e lavagna da cucina per la lista della spesa | **+** Immediati e a basso costo.<br>**+** Visibilità fisica istantanea nel momento in cui si è in cucina.<br>**-** Non accessibili da remoto (es. al supermercato).<br>**-** Non condivisibili digitalmente tra coinquilini.<br>**-** Nessun alert automatico per i prodotti in scadenza. |

### Scenario 3: L'inventario manuale che non si fa mai
**Attore:** Elena, 38 anni, project manager e madre di due figli. Si occupa dell'intera logistica domestica familiare.

**Scenario:** Ogni sabato mattina Elena controlla fisicamente frigorifero, dispensa e stipetti per capire cosa serve. Impiega 15-20 minuti per questo inventario, dopodiché redige la lista su carta. Si accorge che ogni settimana compra quasi sempre gli stessi prodotti: 4 litri di latte, 2 yogurt per i figli, il caffè, la pasta. Vorrebbe che qualcuno — o qualcosa — imparasse le sue abitudini di consumo e le preparasse già la lista. Spesso, durante la settimana, prodotti di "back-up" (sale, olio, detergente) terminano senza che nessuno se ne accorga, perché il loro consumo è troppo lento e graduale per essere rilevato senza monitoraggio.

**Claims Scenario 3**
| Situation Features | Pros(+) e Cons(-) |
| :--- | :--- |
| Inventario visivo manuale + lista cartacea settimanale | **+** Controllo diretto e accurato sull'inventario fisico.<br>**-** Processo lento, ripetitivo e ad alto carico cognitivo.<br>**-** Non avvisa delle scadenze imminenti.<br>**-** Non apprende le abitudini di consumo nel tempo.<br>**-** Lista non condivisibile in tempo reale con altri familiari. |

---

## 3. Piano di indagine contestuale

L'obiettivo dell'indagine è triplice:
1. Validare il **problema** (la gestione della dispensa e della spesa è inefficiente e frammentata per i gruppi domestici).
2. Valutare la **rilevanza** delle singole funzionalità di AvanziZero rispetto alle abitudini reali degli utenti.
3. Misurare la **propensione all'adozione** di un sistema IA predittivo per la lista della spesa.

Il target è stato segmentato in due cluster principali:
- **Cluster A (Condiviso / Fuorisede):** 3-4 persone per appartamento, basso coordinamento, acquisti frequenti e piccoli.
- **Cluster B (Strutturato / Famiglia):** 2-4 persone, acquisti settimanali programmati, una figura "capofamiglia" che coordina.

### 3.1 Prima fase: Questionario di Screening
Somministrato a 50 candidati per isolare il campione più rilevante (chi fa la spesa per sé o per un gruppo):
- Con quante persone condividi la casa? Chi di voi fa solitamente la spesa?
- Come decidi cosa acquistare al supermercato? (Memoria, lista cartacea, app, WhatsApp)
- Ti è mai capitato di acquistare un prodotto già presente a casa, o di scoprire un prodotto scaduto in dispensa?
- Quanto tempo dedichi a preparare la lista della spesa? Ti pesa come compito?
- Saresti disposto a usare un'app che monitora la tua dispensa e ti avvisa delle scadenze in automatico?

### 3.2 Seconda fase: Contextual Inquiry Face-to-Face
*(Master-Apprentice model: l'utente mostra, l'interviewer osserva)*

Campione finale: **15 persone** (40% Cluster A, 60% Cluster B), intervistate nel loro ambiente domestico (cucina) o nei pressi di supermercati.

**Domande di contesto durante l'osservazione:**
- "Mostrami come fai la lista della spesa normalmente."
- "Come sai che quel prodotto è esaurito? Lo controlli visivamente o vai a memoria?"
- "Hai mai scoperto un prodotto scaduto in dispensa che non sapevi ci fosse? Come reagisci?"
- "Se un'app ti mostrasse una notifica 'Il latte sembra quasi esaurito, vuoi aggiungerlo alla lista?', come ti comporteresti?"
- "Quanto ti pesa il compito di ricordare cosa comprare? Ci perdi tempo mentale anche durante la settimana?"

### 3.3 Profili del campione intervistato

| Sesso | Età | Occupazione | Tipologia abitativa | Strumento attuale |
| :---: | :---: | :--- | :--- | :--- |
| F | 22 | Studentessa | Coinquilini (4 pax) | WhatsApp |
| M | 25 | Dottorando | Coinquilini (2 pax) | Memo iPhone |
| F | 36 | Avvocato | Famiglia (3 pax) | Carta e penna |
| M | 30 | Ingegnere | Coppia (2 pax) | Foglio Excel condiviso |
| M | 27 | Sviluppatore | Single | Assistente vocale |
| F | 42 | Insegnante | Famiglia (4 pax) | Lista cartacea + lavagna |
| ... | ... | *[campione totale: 15 persone]* | ... | ... |

---

## 4. Analisi dei risultati

### 4.1 Quali attività svolgono al momento gli utenti?
Gli utenti gestiscono la dispensa in modo **reattivo e analogico**: scoprono che un prodotto manca solo quando è già esaurito. La lista della spesa viene redatta manualmente, con grande sforzo cognitivo, pochi minuti prima di uscire di casa. La comunicazione tra coinquilini avviene su canali non strutturati (WhatsApp, verbale). Il monitoraggio delle scadenze dei prodotti non avviene quasi mai, causando sprechi settimanali.

### 4.2 Quali task vorrebbero svolgere?
Gli utenti vogliono **azzerare la fase di pianificazione**. Vogliono aprire un'app e trovare un inventario aggiornato della loro dispensa, una lista della spesa già precompilata con i prodotti che stanno per finire, e la certezza che i coinquilini stiano lavorando sullo stesso documento in tempo reale. In sintesi: vogliono passare da "gestire la casa" a "confermare ciò che il sistema ha già capito".

### 4.3 Come vengono apprese le attività?
AvanziZero si basa su un modello di apprendimento **progressivo e passivo**: il sistema impara dai comportamenti dell'utente (aggiunta di prodotti, cancellazione, spunta "spesa fatta") senza che l'utente debba configurare esplicitamente nulla. La curva di apprendimento è quasi nulla: l'interfaccia si basa su pattern noti (liste, categorie, swipe) familiari a chiunque abbia mai usato uno smartphone.

### 4.4 Dove vengono svolte le attività?
- **In cucina (home):** Aggiunta prodotti in dispensa, verifica scadenze, creazione voci nella lista della spesa.
- **In mobilità (mezzi, pausa pranzo):** Revisione della lista prima di uscire, aggiunta di prodotti dimenticati.
- **Al supermercato:** Consultazione della lista e spunta dei prodotti acquistati. Qui la connessione è spesso debole: l'app deve funzionare offline.

### 4.5 Che relazione c'è tra utente e dati? (Privacy)
Gli utenti si mostrano disposti a condividere i propri dati di consumo alimentare purché le finalità siano chiare e i dati non vengano ceduti a terze parti per pubblicità aggressiva. La conformità GDPR è percepita come un requisito imprescindibile per la fiducia. I dati di consumo del gruppo devono restare all'interno del gruppo stesso.

### 4.6 Quali altri strumenti ha l'utente per completare il task?
- **WhatsApp/Telegram:** usati come lista condivisa di fortuna. Non strutturati, il messaggio si perde.
- **Google Keep / Apple Notes:** liste digitali semplici, non collaborative in tempo reale, prive di logica di inventario.
- **Bring! / OurGroceries:** app dedicate alla spesa, ma richiedono inserimento manuale puro, nessuna predizione.
- **Alexa / Google Home:** utili per l'inserimento vocale, ma richiedono un'azione attiva nel momento esatto in cui il prodotto finisce.

Nessuna soluzione attuale integra inventario, scadenze, collaborazione in tempo reale e predizione IA in un'unica piattaforma.

### 4.7 Come comunicano gli utenti tra loro?
La comunicazione è **asincrona e non strutturata**. Un coinquilino che finisce l'olio lo scrive su WhatsApp solo se ci pensa. Chi fa la spesa deve raccogliere tutte le segnalazioni sparse. AvanziZero sostituisce questa catena comunicativa fragile con un **inventario condiviso e sincronizzato**: qualsiasi membro del gruppo può aggiungere elementi alla lista, e l'IA aggiornerà proattivamente i suggerimenti senza richiedere comunicazioni umane intermedie.

### 4.8 Con quale frequenza sono eseguiti i task?
- **Macro-spesa settimanale** (sabato/domenica): 1-2 volte a settimana, acquisti consistenti (20-40 articoli).
- **Micro-spesa quotidiana** (pane, frutta fresca, affettati): quotidiana o bisettimanale, 2-5 articoli.
- **Controllo scadenze:** quasi mai, a meno che non si noti visivamente qualcosa di sospetto.

### 4.9 Quali sono i vincoli di tempo?
- La consultazione della lista al supermercato deve richiedere pochi secondi per voce.
- L'aggiunta di un prodotto in dispensa (post-acquisto) deve richiedere meno di 10 secondi per item, altrimenti l'utente rinuncia.
- La revisione dei suggerimenti IA deve richiedere meno di 30 secondi totali.

### 4.10 Cosa accade quando le cose vanno male?
- **Prodotto non trovato al supermercato:** l'utente vuole poter spostare facilmente un item dalla lista della spesa a "da cercare altrove", senza eliminarlo.
- **Predizione IA errata:** l'utente deve poter scartare un suggerimento in modo rapido e frictionless. Ogni rifiuto diventa feedback per l'algoritmo.
- **Nessuna connessione:** la lista della spesa e la dispensa devono essere disponibili in modalità offline, sincronizzando con Firebase al ritorno della rete.
- **Membro del gruppo rimosso:** l'utente rimosso deve ricevere un chiaro avviso e non deve poter più accedere ai dati del gruppo.

---

## 5. Annotazioni (fatti osservati)

1. **Il "problema dei prodotti invisibili":** I beni di consumo lento (sale, olio, zucchero, carta igienica, detersivo) sono i più dimenticati perché non rientrano mai nel campo visivo quotidiano dell'utente. Sono esattamente quelli che l'IA predittiva intercetta meglio, essendo a consumo ciclico e prevedibile.

2. **La resistenza all'inventario digitale iniziale (Cold-Start):** Caricare tutta la dispensa nel sistema al primo accesso è percepito come un compito enorme. La funzionalità di **scansione OCR degli scontrini** è la risposta diretta a questo ostacolo: l'utente fotografa lo scontrino della spesa e l'app popola automaticamente la dispensa.

3. **Il "momento d'oro" della spesa:** L'unico momento in cui l'utente è completamente attivo nella gestione della lista è al supermercato. È lì che l'interfaccia deve essere massimamente semplice e usabile con una mano sola, senza distrazioni.

4. **Fiducia nell'IA: generazionale e condizionata:** Gli utenti più giovani (20-28 anni) accettano volentieri le predizioni dell'IA come punto di partenza. Gli utenti più maturi (35+ anni) le accettano solo se presentate come "suggerimenti" e non come "decisioni" prese al posto loro. L'interfaccia del banner "Predictive Shopping" di AvanziZero rispetta questo principio: mostra i suggerimenti ma li subordina alla conferma manuale dell'utente.

5. **Il "codice casa" come elemento di fiducia:** Nelle interviste con i coinquilini, è emerso che il meccanismo di condivisione tramite **codice casa univoco** (es. "CASA-7B4D") è immediatamente compreso e apprezzato come alternativa semplice e sicura rispetto a sistemi basati su email o link. Elimina la frizione dell'onboarding collettivo.
