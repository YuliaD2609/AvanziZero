# 🎨 Style Guide: Palette Cromatica "Pastel Sage & Soft Mint"

Questa guida definisce il sistema cromatico ufficiale per l'applicazione **FarFromHome**, appositamente studiato per il target di **studenti fuorisede** e orientato ai valori di **sostenibilità ("Zero Spreco")**, **collaborazione** e **organizzazione senza stress**.

---

## 1. Concept & Psicologia del Colore
L'utilizzo di toni pastello naturali desaturati garantisce un'esperienza visiva rilassante e accogliente, riducendo il carico cognitivo associato alla gestione della casa e delle spese.
* **Il Verde Salvia:** Evoca freschezza, natura ed equilibrio. Rappresenta il pilastro del risparmio alimentare.
* **Il Pesca Pastello:** Sostituisce l'arancione puro o il rosso aggressivo per trasmettere energia positiva, calore e giovinezza in un contesto informale di co-living.
* **L'Avorio Soft:** Sostituisce i grigi freddi o il bianco clinico come sfondo generale, rendendo l'ambiente familiare e confortevole.

---

## 2. I Colori di Brand (Primary & Accent)

| Ruolo Semantico | Nome Colore | HEX | RGB | Utilizzo UI |
| :--- | :--- | :--- | :--- | :--- |
| **Primary** | Verde Salvia Intenso | `#5A9E87` | `90, 158, 135` | Barre di navigazione (Top/Bottom), icone attive, bottoni primari, intestazioni di sezione. |
| **Primary Gradient** | Salvia & Menta | `linear-gradient` | N/A | `linear-gradient(135deg, #5A9E87, #76B59D)` per header grafici e copertine dal look premium. |
| **Accent** | Pesca Pastello | `#FFB088` | `255, 176, 136` | Floating Action Button (FAB), badge interattivi dell'Intelligenza Artificiale, inviti all'azione (CTA). |

---

## 3. Superfici e Sfondi (Background & Surfaces)

| Ruolo Semantico | Nome Colore | HEX | RGB | Utilizzo UI |
| :--- | :--- | :--- | :--- | :--- |
| **Background** | Avorio Soft | `#FBFBF9` | `251, 251, 249` | Sfondo root dell'applicazione. Distende la vista e crea un morbido contrasto con le schede. |
| **Surface (Card)** | Bianco Puro | `#FFFFFF` | `255, 255, 255` | Sfondo di schede, liste della spesa, modali e popup. |
| **Surface Border**| Grigio Nebbia | `#EAECE8` | `234, 236, 232` | Bordi sottili di separazione tra elementi e divisori interni. |

---

## 4. Gerarchia del Testo (Typography Colors)
Per garantire una leggibilità eccellente (accessibilità WCAG), evitiamo il nero puro e utilizziamo tonalità derivate dal verde foresta, mantenendo la coerenza visiva.

| Ruolo Semantico | Nome Colore | HEX | RGB | Utilizzo UI |
| :--- | :--- | :--- | :--- | :--- |
| **Text Main** | Verde Foresta Scuro | `#1C3D32` | `28, 61, 50` | Titoli principali, testo dei paragrafi, voci di spesa e bilanci. **Contrasto elevatissimo.** |
| **Text Muted** | Salvia Desaturato | `#789088` | `120, 144, 136` | Sottotitoli, date di inserimento, descrizioni secondarie e placeholder. |
| **Text On Primary**| Bianco Puro | `#FFFFFF` | `255, 255, 255` | Testo posizionato sopra bottoni primari o header verdi. |
| **Text On Accent** | Verde Foresta Scuro | `#1C3D32` | `28, 61, 50` | Testo posizionato sopra elementi accento color pesca per garantire contrasto. |

---

## 5. Colori Semantici e di Stato (Feedback & Notifiche)
Colori riservati esclusivamente a comunicare lo stato della dispensa, delle spese e degli avvisi.

* 🟢 **Successo / Cibo Fresco (`#22C55E` - Sfondo leg. `#D1FAE5`):** Prodotto aggiunto correttamente o con lunga scadenza.
* 🟡 **Attenzione / Scadenza a Breve (`#F59E0B` - Sfondo leg. `#FEF3C7`):** Cibo in scadenza tra 2-3 giorni o spesa in attesa di saldo.
* 🔴 **Critico / Scaduto o Urgente (`#EF4444` - Sfondo leg. `#FEE2E2`):** Prodotto scaduto o azione irreversibile (es. uscita da un gruppo appartamento).

---

## 6. Regole di Applicazione (Design System)
1. **Regola del 60-30-10:**
   * **60%** dell'interfaccia: Sfondi chiari (`#FBFBF9` e `#FFFFFF`).
   * **30%** dell'interfaccia: Colore Primario (`#5A9E87`) e testo scuro.
   * **10%** dell'interfaccia: Accenti color Pesca (`#FFB088`) per guidare l'azione dell'utente.
2. **Ombreggiature (Shadows):**
   * Non usare ombre nere e dure. Utilizza un'ombra morbida e tinta di verde per un effetto *glassmorphism* di alta qualità: `box-shadow: 0 4px 20px rgba(28, 61, 50, 0.05);`.
