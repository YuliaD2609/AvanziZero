# FarFromHome - Mobile App per Fuorisede

Applicazione mobile in **Flutter** progettata per ottimizzare la gestione della casa, l'organizzazione della spesa e l'integrazione di coinquilini per studenti fuorisede, supportata da funzionalità intelligenti basate sul **Business Model Canvas**.

---

## 📂 Struttura del Repository

Il progetto è stato sottoposto a una profonda pulizia per isolare il codice attivo e organizzarlo secondo i migliori standard universitari:

* **`flutter_app/`**: Contiene l'intera applicazione sorgente in Flutter/Dart ad alta fedeltà.
  * `lib/main.dart`: Punto di ingresso, provider dello stato globale e gestione barra di navigazione principale.
  * `lib/models/app_state.dart`: Logica reattiva nativa e gestione intatta delle categorie predefinite.
  * `lib/screens/`: Interfacce ottimizzate (Home, Dispensa, Lista della Spesa).
  * `lib/widgets/`: Componenti modulari e interfaccia per l'acquisizione scontrini tramite **Intelligenza Artificiale (OCR)**.
* **`documentazione/`**: Contiene tutti i deliverable di analisi e design del progetto.
  * `canvas.html`: **Business Model Canvas** interattivo e renderizzato graficamente.
  * `palette.md`: Specifica dei token colore della Style Guide ("Pastel Sage & Soft Mint").
  * `fonts.md`: Gerarchia e scala tipografica mobile basata sul font *Outfit*.

---

## ✨ Funzionalità Principali (Core Value Propositions)

1. **Dispensa "Zero Spreco":** Monitoraggio intelligente dei prodotti e alert cromatico automatico per le date di scadenza.
2. **Lista della Spesa Predittiva:** Avvisi proattivi basati sulle abitudini di consumo prima che le scorte terminino, con trasferimento automatico in dispensa ("Spesa Fatta").
3. **House Sync (Spese Condivise):** Sincronizzazione in tempo reale e calcolo automatico dei saldi tra coinquilini.
4. **Ottimizzazione Tempi:** Ricerca immediata dei supermercati convenzionati nelle vicinanze basata su mappe.

---

## 🚀 Come avviare il progetto da Android Studio

1. Apri **Android Studio** e seleziona **Open**.
2. Seleziona specificamente la sottocartella **`flutter_app`** (non la cartella radice).
3. Apri il file `pubspec.yaml` e clicca su **Pub get** nella barra superiore per scaricare le dipendenze.
4. Seleziona l'emulatore o il dispositivo dal menu a tendina e clicca su **Run (▶️)**.
