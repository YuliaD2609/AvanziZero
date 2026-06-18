# 1. Introduzione al progetto

L'applicativo mobile **AvanziZero** si posiziona come una soluzione avanzata per la gestione collaborativa dell'inventario domestico (dispensa) e l'ottimizzazione degli acquisti (lista della spesa). L'app è rivolta a gruppi di utenti — quali coinquilini, studenti fuorisede e nuclei familiari — che necessitano di sincronizzare in tempo reale le proprie esigenze di approvvigionamento per minimizzare gli sprechi alimentari, evitare acquisti ridondanti e ridurre il carico cognitivo legato alla pianificazione.

Il valore differenziante del progetto risiede nell'integrazione di un motore di **Intelligenza Artificiale Predittiva** (Machine Learning). L'obiettivo dell'IA è passare da un paradigma reattivo (l'utente compila manualmente la lista) a un paradigma proattivo: analizzando lo storico degli acquisti e le abitudini di consumo, il sistema predice autonomamente l'esaurimento dei prodotti e genera una proposta di lista della spesa intelligente. L'utente non dovrà fare altro che approvare o scartare i suggerimenti proposti prima di recarsi al punto vendita, ottimizzando drasticamente il tempo investito nel task.

---

# 2. Problem scenario

## Scenario 1: La gestione frammentata tra fuorisede
**Attore:** Lorenzo, 22 anni, studente universitario di Ingegneria. Vive con altri tre coinquilini. Ha ritmi di vita irregolari e si occupa della spesa nei rari momenti di vuoto tra le lezioni. Non c'è una chiara divisione dei compiti in casa.

**Scenario:** È venerdì sera, Lorenzo esce dall'università e decide di passare al supermercato per comprare la cena. Per capire cosa manca, apre il gruppo WhatsApp della casa ("Spesa Via Roma"). I messaggi sono confusi, mescolati a meme e conversazioni off-topic. Cerca di fare mente locale su cosa ha visto in frigo quella mattina, ma non è sicuro. Decide di comprare uova, latte e pasta. Arrivato a casa, scopre che un altro coinquilino aveva già comprato il latte due ore prima, mentre manca totalmente il sale, essenziale per la cena. Lorenzo pensa a quanto sarebbe utile un sistema centralizzato che gli notifichi in tempo reale, tramite un'analisi predittiva, esattamente cosa sta per finire.

**Claims Scenario 1**

| Situation Features | Pros(+) e Cons(-) |
| :--- | :--- |
| **Utilizzo di WhatsApp e della memoria a breve termine per gli acquisti** | **+** Nessuna barriera all'ingresso (tool già in uso).<br>**+** Comunicazione istantanea.<br>**-** Dispersione informativa a causa del rumore di fondo (off-topic).<br>**-** Rischio elevato di *double purchasing* (acquisti doppi) con conseguente spreco economico.<br>**-** Inefficienza nell'inventario reale della dispensa. |

## Scenario 2: Il sovraccarico organizzativo familiare
**Attore:** Elena, 38 anni, project manager e madre di due figli. Gestisce l'intera logistica familiare. Ha un approccio metodico ma il suo tempo libero è estremamente limitato.

**Scenario:** È sabato mattina, il momento dedicato alla "grande spesa" settimanale. Prima di uscire, Elena spende circa 20 minuti per fare un inventario manuale: apre frigorifero, congelatore e stipetti, annotando tutto su un block notes cartaceo. Durante questa procedura meccanica, si rende conto che la famiglia consuma regolarmente gli stessi prodotti (es. 4 litri di latte, 2 pacchi di biscotti, 1 kg di petto di pollo a settimana). Trova frustrante dover ricalcolare queste necessità ogni volta. Vorrebbe un assistente digitale che, appresi i pattern di consumo della sua famiglia, precompilasse la lista con l'80% dei prodotti ricorrenti, lasciando a lei solo l'onere di aggiungere gli sfizi o i prodotti extra.

**Claims Scenario 2**

| Situation Features | Pros(+) e Cons(-) |
| :--- | :--- |
| **Inventario manuale e lista cartacea** | **+** Altissimo grado di affidabilità e controllo sullo stato reale della dispensa.<br>**+** Semplicità d'uso durante la spesa fisica nel negozio.<br>**-** Operazione *time-consuming* e ad alto carico cognitivo (ripetitiva).<br>**-** Impossibilità di condividere la lista in tempo reale con il partner (se lui passa dal supermercato, non ha il foglio).<br>**-** Nessuna ottimizzazione basata sullo storico degli acquisti. |

## Scenario 3: L'incapacità di tracciare la scadenza dei prodotti (Food Waste)
**Attore:** Matteo, 29 anni, consulente finanziario, vive da solo. Lavora fino a tardi e ordina spesso cibo a domicilio, facendo la spesa in modo sregolato.

**Scenario:** Matteo decide di cucinare per risparmiare. Va al supermercato e, non ricordando bene cosa ci sia in casa, acquista confezioni di affettati, verdura fresca e formaggi. Tornato a casa, inserendo la spesa nel frigo, trova verdure marce e formaggi scaduti acquistati la settimana precedente e completamente dimenticati nel cassetto in basso. Frustrato per lo spreco di soldi e cibo, realizza che necessita di un sistema che non solo tenga traccia di ciò che possiede, ma che anticipi le scadenze e lo aiuti a comprare *solo* ciò che serve, basandosi sui suoi ritmi di consumo irregolari.

**Claims Scenario 3**

| Situation Features | Pros(+) e Cons(-) |
| :--- | :--- |
| **Acquisti impulsivi senza tracking dell'inventario** | **+** Nessun tempo speso nella pianificazione.<br>**-** Altissimo tasso di spreco alimentare (*food waste*).<br>**-** Frustrazione e perdita economica.<br>**-** Inconsapevolezza totale di ciò che si possiede. |

---

# 3. Piano di indagine contestuale

Al fine di validare l'architettura informativa dell'app e tarare gli algoritmi di predizione, è stata condotta un'indagine sul target di riferimento: il *decision-maker* degli acquisti domestici. Abbiamo segmentato il campione in due cluster principali:
1. **Cluster A (Condiviso):** Studenti fuorisede e coinquilini (basso budget, alta frequenza di acquisti piccoli, bassa organizzazione).
2. **Cluster B (Strutturato):** Lavoratori e famiglie (budget medio-alto, acquisti settimanali programmati, alta organizzazione).

Gli obiettivi manageriali dell'indagine sono:
- Mappare il *Customer Journey* della compilazione della lista della spesa.
- Quantificare il *pain point* legato al tempo perso per l'inventario.
- Misurare l'apertura e la fiducia (Trust) verso un'Intelligenza Artificiale che automatizza le decisioni d'acquisto.
- Identificare le piattaforme e i workaround attualmente in uso.

## 3.1 Screening iniziale (Questionario)

Per isolare il campione più rilevante, è stato somministrato un sondaggio preliminare a 50 utenti, con le seguenti domande chiave:
- Condividi le responsabilità della spesa con altre persone (partner, coinquilini)?
- Che strumento usi attualmente per la lista della spesa? (Carta, WhatsApp, App dedicata, Memoria).
- Quanto frequentemente ti capita di acquistare doppioni o dimenticare prodotti base?
- Saresti disposto a condividere i dati sui tuoi consumi con un algoritmo se questo ti facesse risparmiare 15 minuti a settimana?

## 3.2 Indagine sul campo (Contextual Inquiry Face-to-Face)

Tra i rispondenti, è stato selezionato un campione di 15 utenti per un'intervista contestuale (*Master-Apprentice model*). Agli intervistati è stato chiesto di:
1. **Simulare l'attività:** "Mostrami esattamente cosa fai quando capisci che devi fare la spesa".
2. **Think-aloud:** Agli utenti è stato chiesto di pensare ad alta voce mentre aprivano il frigo o scrivevano la lista sul telefono.

In questo modo è stato possibile osservare non ciò che l'utente *dice* di fare, ma ciò che *fa realmente* nel suo contesto abitativo.

## 3.3 Modalità di somministrazione

L'indagine è stata condotta direttamente nelle cucine/ambienti domestici degli intervistati, o nei pressi di supermercati. Il team di ricerca si è diviso i ruoli:
- **Intervistatore (Apprentice):** Poneva domande di chiarimento ("Perché hai aperto quello stipetto senza scrivere nulla?").
- **Osservatore (Recorder):** Annotava le frizioni, i tempi morti e le esitazioni, registrando i dati oggettivi.

### 3.4 Risultati ottenuti (Demografia del campione)

| Sesso | Età | Lavoro | Tipologia Abitativa | Strumento Attuale |
| :---: | :---: | :--- | :--- | :--- |
| M | 22 | Studente | Coinquilino (3 pax) | WhatsApp / Memoria |
| F | 24 | Neolaureata | Coinquilino (2 pax) | Memo Smartphone |
| F | 36 | Avvocato | Famiglia (3 pax) | Carta e penna |
| M | 30 | Ingegnere | Convivenza (2 pax) | Excel condiviso |
| M | 27 | Sviluppatore | Single | Assistente Vocale |
| ... | ... | *[Dati omessi per brevità]* | ... | ... |

*(Il campione totale di 15 persone riflette un mix 40% Cluster A, 60% Cluster B)*

---

# 4. Analisi dei risultati delle indagini contestuali

## 4.1 Quali attività svolgono al momento gli utenti?
Il processo attuale è altamente analogico e frammentato. Oltre l'80% degli intervistati esegue un "inventario visivo" aprendo fisicamente frigorifero e dispense prima di redigere la lista. Per i gruppi (famiglie/coinquilini), il task prevede un passaggio extra: il consolidamento delle richieste ("Ragazzi, vado al supermercato, serve qualcosa?"). Molti si affidano a WhatsApp, ma la non-strutturazione dei messaggi causa un alto tasso di errore (es. dimenticanze) stimato intorno al 15-20% degli articoli essenziali.

## 4.2 Quali task vorrebbero svolgere?
Gli utenti desiderano azzerare il *cognitive load* (carico cognitivo) legato alla pianificazione. Vorrebbero aprire un'app e trovare una lista **già popolata** in base a deduzioni logiche. Il task primario che vogliono svolgere non è più "Scrivere la lista", ma **"Revisionare e approvare"** la lista creata dall'IA, aggiungendo solo eventuali acquisti straordinari (es. ingredienti per una cena speciale).

## 4.3 Come vengono apprese le attività da svolgere?
Essendo un'applicazione B2C ad alto impatto quotidiano, l'apprendimento deve rientrare nel paradigma *Zero-UI* o *Passive Learning*. L'utente non deve impostare complessi parametri ("Avvisami ogni 7 giorni per il latte"). Il sistema impara in modo invisibile: ogni volta che l'utente spunta un elemento acquistato, l'IA aggiorna il modello predittivo. L'interfaccia si baserà su pattern noti (swipe per accettare o scartare un suggerimento), annullando la curva d'apprendimento.

## 4.4 Dove vengono svolte le attività?
- **Pianificazione (Generazione Lista):** Avviene nel 70% dei casi a casa, e nel 30% dei casi in mobilità (sui mezzi pubblici, durante le pause a lavoro). L'IA è vitale in mobilità, poiché l'utente non può controllare fisicamente la dispensa e si affida ciecamente alla memoria.
- **Esecuzione (Acquisto):** Avviene all'interno del supermercato, dove l'attenzione dell'utente è frammentata e l'uso dello smartphone deve essere eseguibile con una sola mano (*one-handed operation*).

## 4.5 Che relazione c’è tra utente e dati? (Privacy e Sensibilità)
I dati raccolti (frequenza di spesa, tipologia di prodotti consumati) definiscono il profilo dietetico e lo stile di vita dell'utente. Durante le interviste, il 90% degli utenti si è detto disposto a cedere questi dati all'algoritmo *solo* a patto di una rigida politica di privacy. Gli utenti considerano questi dati "Personali Sensibili" se legati ad abitudini alimentari specifiche (es. acquisto di medicinali da banco, alcolici). È emersa l'esigenza che l'elaborazione dell'IA avvenga garantendo che i dati non vengano ceduti a terze parti (es. GDO) per pubblicità aggressiva.

## 4.6 Quali altri strumenti ha l’utente per completare il task?
Attualmente il mercato offre:
- **App di Todo/Note generiche (Google Keep, Apple Notes):** Permettono la condivisione, ma sono "stupide" (non elaborano i dati).
- **App dedicate alla spesa (Bring!, Any.do):** Ottime interfacce, ma reattive. Richiedono l'input manuale dell'utente per ogni singolo prodotto.
- **Ecosistemi IoT (Alexa, Google Home):** Consentono l'inserimento vocale *hands-free*, utile ma dipendente dalla memoria immediata dell'utente nel momento esatto in cui finisce il prodotto. Nessuno di questi anticipa il bisogno tramite ML.

## 4.7 Come comunicano gli utenti tra loro relativamente ai task?
La comunicazione è profondamente asincrona e caotica (WhatsApp). Il limite maggiore osservato è che spesso un coinquilino termina un prodotto (es. l'olio) di martedì, ma dimentica di comunicarlo. Chi andrà a fare la spesa di venerdì non saprà della mancanza. AvanziZero agisce come un layer di comunicazione silente: se l'IA deduce che l'olio dovrebbe essere finito, lo notificherà a chi fa la spesa, bypassando la necessità di comunicazione umana diretta, incline all'errore.

## 4.8 Con quale frequenza sono eseguiti i task?
Si osservano due macro-pattern:
- **Macro-spesa (Settimanale):** Spesa grossa (es. sabato mattina), per la quale si spende molto tempo a pianificare. L'IA qui fornirà una predizione massiva (20-30 articoli).
- **Micro-spesa (Giornaliera/Bisettimanale):** Acquisti mirati (es. pane, affettati). L'IA qui agirà con notifiche push *context-aware* (es. "Stai passando vicino al supermercato? Il pane scade oggi").

## 4.9 Quali sono i vincoli di tempo sui task, se ce ne sono?
Il vincolo è categorico: **la revisione della lista generata dall'IA deve richiedere meno tempo della stesura manuale di una lista.** Dai test è emerso che se l'utente deve spendere più di 45 secondi a correggere previsioni errate (falsi positivi), il Trust nel sistema crolla e l'app viene percepita come un ostacolo, non come un aiuto.

## 4.10 Che accade quando le cose vanno male durante l’esecuzione dei task?
Cosa accade se l'IA ha un'allucinazione e suggerisce di comprare 10 litri di latte? Il sistema gestisce l'errore permettendo una correzione *frictionless* (es. swipe to delete). Il fallimento (errore di predizione) diventa l'input per il rinforzo dell'algoritmo. Se l'utente non trova rete al supermercato, l'app prevede un'architettura *offline-first*: l'ultima lista predetta e la dispensa sincronizzata restano accessibili dalla cache locale (es. tramite SharedPreferences/SQLite).

---

# 5. Annotazioni

**Team AvanziZero:**
- *Ricercatore/UX Expert:* [Nome Cognome] - Osservatore ed elaborazione metriche.
- *Ingegnere del Software:* [Nome Cognome] - Intervistatore (focus sulla fattibilità IA e data collection).

**Fatti empirici osservati:**
1. **L'Illusione della Memoria:** Gli intervistati dichiarano di sapere cosa hanno nel frigo. Sottoposti al test pratico ("Dimmi cosa c'è, poi andiamo a controllare"), il tasso di errore è stato del 40%. La memoria umana per oggetti a basso valore affettivo è inaffidabile.
2. **I Prodotti "Invisibili":** Beni di lunghissimo consumo (sale, pepe, detersivo per piatti, pellicola) sono quelli che causano più frustrazione quando mancano, poiché non rientrano mai nel "ciclo visivo" dell'utente fino al momento del bisogno acuto. È qui che l'IA fornirà l'effetto "WOW" maggiore, tracciandone i consumi a lungo termine.
3. **Fiducia condizionata (Trust nell'IA):** I soggetti più maturi (Cluster B) sono scettici verso un'app che "decide per loro". Reclamano il controllo totale. La UI dovrà quindi presentare i suggerimenti dell'IA non come imposizioni, ma sotto forma di una sezione discreta "Potrebbe servirti anche...", lasciando all'utente l'azione di *Opt-in* (aggiungi).
4. **Resistenza all'inventario iniziale (Cold-Start Problem):** Caricare l'intera dispensa il primo giorno è percepito come uno scoglio enorme. Sarà fondamentale integrare tecnologie come lo Scanner di Codici a Barre o OCR degli scontrini per automatizzare l'inserimento dati iniziale e alimentare subito l'IA.
