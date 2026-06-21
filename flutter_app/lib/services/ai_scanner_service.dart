import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/app_state.dart';
import '../services/local_ai_model.dart';
import '../services/local_receipt_parser.dart';
import '../services/wordpiece_tokenizer.dart';

class AIScannerService {
  static const int MAX_LEN = 32;
  static const int NUM_TAGS = 4; // O, B-PROD, I-PROD, B-QTY
  static final Map<int, String> idsToTags = {0: "O", 1: "B-PROD", 2: "I-PROD", 3: "B-QTY"};

  static Future<List<ItemModel>> scanReceipt(XFile imageFile) async {
    try {
      // 1. STADIO 1: OCR (Google ML Kit)
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      String fullText = recognizedText.text;

      // 2. Inizializza Tokenizer
      final tokenizer = WordPieceTokenizer();
      await tokenizer.loadVocab('assets/models/vocab.txt');

      // 3. STADIO 2: NLP NER in TFLite
      Interpreter? interpreter;
      try {
        interpreter = await Interpreter.fromAsset('assets/models/receipt_ner_distilbert.tflite');
        print("Modello TFLite Ibrido caricato con successo!");
      } catch (e) {
        print("Modello TFLite non trovato. Fallback all'estrattore Furbo Locale.");
      }

      List<ItemModel> scannedItems = [];

      if (interpreter != null && tokenizer.isLoaded) {
        // [ARCHITETTURA IBRIDA]: TFLite estrae, Fuzzy corregge
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            String rawLine = line.text;
            if (rawLine.trim().length < 3) continue;

            var inputIds = tokenizer.tokenize(rawLine, maxLen: MAX_LEN);
            // Crea attention mask (1 per i token validi, 0 per i pad)
            var attentionMask = inputIds.map((id) => id == 0 ? 0 : 1).toList();

            // Preparazione tensori
            var inputTensorIds = [inputIds];
            var inputTensorMask = [attentionMask];
            
            // Output tensor shape [1, MAX_LEN, NUM_TAGS]
            var outputTensor = List.generate(1, (_) => List.generate(MAX_LEN, (_) => List.filled(NUM_TAGS, 0.0)));

            // Il convertitore TFLite ordina gli input in ordine alfabetico ('attention_mask' prima di 'input_ids')!
            // Li passiamo in modo dinamico leggendo il nome:
            int inputIdsIdx = interpreter.getInputTensor(0).name.contains("input_ids") ? 0 : 1;
            List<Object> inputs;
            if (inputIdsIdx == 0) {
               inputs = [inputTensorIds, inputTensorMask];
            } else {
               inputs = [inputTensorMask, inputTensorIds];
            }

            interpreter.runForMultipleInputs(inputs, {0: outputTensor});

            String extractedProduct = "";
            int extractedQty = 1;
            
            List<int> extractedProductIds = [];
            List<int> extractedQtyIds = [];

            // Mappatura token e label
            for (int i = 1; i < MAX_LEN - 1; i++) { // Salta CLS e SEP
              if (inputIds[i] == 0) break; // Pad
              if (inputIds[i] >= 100) { // Token validi
                 // Argmax
                 List<double> logits = outputTensor[0][i];
                 int bestTagId = 0;
                 double maxLogit = logits[0];
                 for (int j=1; j<NUM_TAGS; j++) {
                   if (logits[j] > maxLogit) {
                     maxLogit = logits[j];
                     bestTagId = j;
                   }
                 }
                 
                 String tag = idsToTags[bestTagId]!;
                 if (tag == "B-PROD" || tag == "I-PROD") {
                    extractedProductIds.add(inputIds[i]);
                 } else if (tag == "B-QTY") {
                    extractedQtyIds.add(inputIds[i]);
                 }
              }
            }

            extractedProduct = tokenizer.decode(extractedProductIds).trim();
            String qtyString = tokenizer.decode(extractedQtyIds).trim();
            extractedQty = int.tryParse(qtyString.replaceAll(RegExp(r'\D'), '')) ?? 1;

            print("--- ANALISI RIGA: '$rawLine' ---");
            print("Token Product Ids: $extractedProductIds");
            print("Extracted Product Text: '$extractedProduct'");
            print("Extracted Qty: $extractedQty");

            if (extractedProduct.length > 2) {
               // [STADIO 3]: Fuzzy Matching locale sull'output neurale
               // Passiamo il prodotto astratto al mega-dizionario per correggere l'OCR ("M3LA" -> "Mela")
               var items = LocalReceiptParser.parseReceiptText(extractedProduct);
               if (items.isNotEmpty) {
                 var item = items.first;
                 print("MATCH TROVATO: ${item.name}");
                 scannedItems.add(ItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString() + item.name.hashCode.toString(),
                    name: item.name,
                    quantity: extractedQty > 1 ? extractedQty : item.quantity,
                    category: item.category,
                    isPantry: true
                 ));
               } else {
                 print("NESSUN MATCH NEL DATABASE PER: $extractedProduct");
               }
            }
          }
        }
        interpreter.close();
      } else {
        scannedItems = LocalReceiptParser.parseReceiptText(fullText);
      }

      // Raggruppa duplicati
      Map<String, ItemModel> groupedItems = {};
      for (var item in scannedItems) {
        if (groupedItems.containsKey(item.name)) {
          var existing = groupedItems[item.name]!;
          groupedItems[item.name] = ItemModel(
              id: existing.id, name: existing.name, expireDate: existing.expireDate,
              quantity: existing.quantity + item.quantity, category: existing.category, isPantry: true);
        } else {
          groupedItems[item.name] = item;
        }
      }
      
      return groupedItems.values.toList();
    } catch (e, stacktrace) {
      print("ERRORE OCR: $e");
      print("STACKTRACE: $stacktrace");
      throw Exception("Errore durante l'analisi OCR offline: $e");
    }
  }

  /// Restituisce suggerimenti predittivi usando il modello AI comportamentale locale
  static Future<Map<String, List<ItemModel>>> getPredictiveSuggestions(
      List<ItemModel> pantryItems,
      List<ItemModel> shoppingItems,
      List<Map<String, dynamic>> consumptionHistory,
      int groupSize) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Manteniamo la fantastica intelligenza statistica in locale
    return LocalPredictiveModel.predict(
        pantryItems, shoppingItems, consumptionHistory, groupSize);
  }
}
