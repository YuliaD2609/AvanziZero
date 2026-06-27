# ML Pipeline - AvanziZero (OCR Offline)

Questa cartella contiene gli script per generare il dataset di scontrini italiani sintetici e addestrare il modello DistilBERT per estrarre prodotti e quantità in modo completamente locale sull'app mobile.

## Prerequisiti
1. Assicurati di avere Python installato sul tuo PC.
2. Installa le librerie aprendo il terminale in questa cartella e lanciando:
   ```bash
   pip install -r requirements.txt
   ```

## Step 1: Generazione del Dataset
Lancia lo script di generazione per creare migliaia di finti scontrini italiani (con "rumore" visivo ed errori tipici OCR).
```bash
python generate_dataset.py
```
Questo creerà il file `receipt_dataset.json` (che farà da materiale di studio per la rete neurale).

## Step 2: Training & Esportazione
Lancia l'addestramento sfruttando la tua potente RTX 4060:
```bash
python train.py
```
*(Nota: Potresti visualizzare dei log di TensorFlow che annunciano l'uso della tua GPU, è del tutto normale).*
Questo script farà il fine-tuning di `distilbert-base-multilingual-cased` per poche epoche, poi congelerà i pesi e comprimerà tutto usando la quantizzazione.

Il risultato finale apparirà in `ai_models/receipt_ner_distilbert.tflite`.

## Step 3: Integrazione in Flutter
Una volta ottenuto il file `.tflite`, copialo nella cartella dell'app Flutter in `assets/ai_models/` (assicurati che sia dichiarato in `pubspec.yaml`).
Il modulo Dart (`LocalReceiptScanner`) lo caricherà automaticamente per analizzare gli scontrini!
