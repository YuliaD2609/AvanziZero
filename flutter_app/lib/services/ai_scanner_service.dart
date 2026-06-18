import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/app_state.dart';
import '../services/local_ai_model.dart';
import '../services/local_receipt_parser.dart';

class AIScannerService {
  
  /// Scansiona uno scontrino usando Google ML Kit OCR (completamente offline)
  /// e poi applica il nostro Parser IA (LocalReceiptParser) per estrarre i prodotti.
  static Future<List<ItemModel>> scanReceipt(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      // Esecuzione OCR Locale
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Chiusura del riconoscitore per liberare memoria
      textRecognizer.close();

      // Passiamo il testo raw (puro) al nostro Parser IA locale
      final List<ItemModel> scannedItems = LocalReceiptParser.parseReceiptText(recognizedText.text);

      if (scannedItems.isEmpty) {
        throw Exception("Non sono riuscito a trovare prodotti riconoscibili nello scontrino.");
      }

      return scannedItems;
    } catch (e, stackTrace) {
      print("=========================================");
      print("ERRORE CRITICO OCR LOCALE");
      print("=========================================");
      print("Dettaglio Errore: $e");
      print("Stack Trace: $stackTrace");
      print("=========================================");
      throw Exception("Errore di lettura dello scontrino: $e");
    }
  }

  /// Restituisce suggerimenti predittivi usando il modello AI comportamentale locale
  static Future<Map<String, List<ItemModel>>> getPredictiveSuggestions(
      List<ItemModel> pantryItems,
      List<ItemModel> shoppingItems,
      List<Map<String, dynamic>> consumptionHistory,
      int groupSize) async {
    
    // Piccolo delay artificiale per far godere all'utente la bella animazione di caricamento richiesta
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Passaggio diretto al nostro modello AI statistico in locale (0 ms di latenza)
    return LocalPredictiveModel.predict(pantryItems, shoppingItems, consumptionHistory, groupSize);
  }
}
