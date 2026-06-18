# 🔤 Style Guide: Tipografia & Gerarchia Visiva

Questa guida stabilisce lo standard tipografico per l'applicazione mobile **AvanziZero**. La scelta dei font è mirata a garantire la massima **leggibilità su schermi mobile**, un'estetica **moderna e premium**, e una chiara **gerarchia dell'informazione** per studenti che consultano l'app frequentemente e in mobilità.

---

## 1. Famiglie Tipografiche Scelte

Per combinare un look giovanile e accogliente con un'interfaccia di gestione precisa e affidabile, adottiamo un approccio a singola famiglia ad altissima versatilità o una combinazione altamente studiata.

### 🌟 Scelta Consigliata: **Outfit** (Google Fonts)
* **Carattere:** Geometrico, pulito, con terminali arrotondati che trasmettono un senso di accoglienza, modernità e design "senza stress".
* **Utilizzo:** Intera interfaccia utente (Titoli e Corpo del testo).
* **Vantaggi:** Rende l'app estremamente contemporanea e premium, distaccandosi dai font di sistema standard.

### 🔄 Alternativa di Sistema: **Inter** o **Roboto**
* Se si preferisce un approccio puramente nativo (specie su Android), **Inter** (per un tocco in stile iOS/Web moderno) o **Roboto** offrono una neutralità e una compatibilità insuperabili per le liste e le tabelle di spesa.

---

## 2. Scala Tipografica (Mobile Typography Scale)

Tutte le dimensioni sono espresse in **sp** (Scale-independent Pixels per Android/Compose) o **rem** (per il Web), con pesi e interlinee calcolati per evitare sovrapposizioni.

| Livello | Dimensione (sp/rem) | Peso (Font Weight) | Interlinea (Line Height) | Utilizzo UI ideale |
| :--- | :--- | :--- | :--- | :--- |
| **Display / App Title** | `32sp` / `2.0rem` | **ExtraBold (800)** | `1.1` | Schermata di benvenuto/onboarding e grandi totali di spesa. |
| **Heading 1 (H1)** | `24sp` / `1.5rem` | **Bold (700)** | `1.2` | Titoli delle schermate principali (es. "Dispensa", "Spese"). |
| **Heading 2 (H2)** | `18sp` / `1.125rem`| **SemiBold (600)** | `1.3` | Intestazioni di card, sezioni interne e nomi dei gruppi/coinquilini. |
| **Body Main** | `15sp` / `0.9375rem`| **Regular (400)** | `1.5` | Voci della lista della spesa, testo dei messaggi e descrizioni. |
| **Body Medium / Bold**| `15sp` / `0.9375rem`| **Medium (500) o Bold**| `1.5` | Importi di spesa e nomi dei prodotti per risaltare nella lista. |
| **Button Text** | `14sp` / `0.875rem` | **Bold (700)** | `1.0` | Testo interno a pulsanti di azione e tab di navigazione (tutto maiuscolo o con iniziale maiuscola). |
| **Caption / Muted** | `12sp` / `0.75rem` | **Regular (400)** | `1.4` | Timestamp, date di scadenza, piccole note e tag dell'IA. |

---

## 3. Linee Guida di UX Tipografica

Per garantire un'interfaccia utente pulita e scansionabile rapidamente:

1. **Allineamento:** 
   * Utilizza sempre l'allineamento **a sinistra** per le liste di prodotti e le descrizioni per assecondare il naturale movimento oculare di lettura.
   * Allinea a destra o in colonna fissa gli **importi finanziari** per facilitare il calcolo visivo del bilancio.
2. **Spaziatura e Interlinea (Line Height):**
   * Un'interlinea generosa (`1.5` sul corpo del testo) è fondamentale in ambito mobile per evitare che l'utente clicchi per errore sulla riga sbagliata.
3. **Lunghezza della riga (Line Length):**
   * Mantieni i blocchi di testo descrittivi entro i **45-60 caratteri** per riga per non affaticare la lettura sul display dello smartphone.
4. **Contrasto Tipografico:**
   * Crea contrasto non solo con il colore, ma variando il **peso (Weight)**: affianca un titolo `Bold` a un sottotitolo `Regular` per chiarire immediatamente la gerarchia visiva.
