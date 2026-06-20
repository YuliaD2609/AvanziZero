import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_state.dart';
import '../services/local_ai_model.dart';

class AIScannerService {
  static Future<List<ItemModel>> scanReceipt(XFile imageFile) async {
    // Leggiamo la chiave dal file .env segreto e non caricato su GitHub
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

    if (apiKey.isEmpty || apiKey == "INSERISCI_QUI_LA_TUA_NUOVA_CHIAVE") {
      throw Exception(
          "API Key mancante! Inserisci la tua chiave nel file .env alla radice del progetto.");
    }

    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );

    final bytes = await imageFile.readAsBytes();

    final prompt = TextPart('''
Sei un assistente AI per un'app di gestione dispensa per studenti fuorisede.
Analizza questo scontrino della spesa (ignora tasse, sconti globali o subtotali).
Per ogni prodotto acquistato, estrai il nome e assegna una categoria logica tra queste: "Frutta & Verdura", "Latticini", "Carne & Pesce", "Secco & Pasta", "Bevande", "Igiene Casa", "Altro".
REGOLE PER IL NOME: Il nome del prodotto DEVE essere estremamente generico e pulito. Ignora marchi, grammature, provenienze geografiche o dettagli inutili. (Esempio: "Uova allevate a terra Piemonte 6pz" -> "Uova", "Coca Cola Zero 1L" -> "Coca Cola", "Latte Arborea Parz. Scremato" -> "Latte").
Per il nome fai una eccezione per prodotti conosciuti internazionalmente come la Coca Cola, in questo caso es. “Coca Cola Zero 1L” -> “Coca Cola”. Eccezione anche formaggi, birre o brand molto conosciuti, non snaturare il prodotto.
Se riesci a dedurre la quantità dallo scontrino inseriscila, altrimenti metti 1.

Non è necessario salvare i sacchetti spesa, quindi ignora l`analisi di essi. Contenitori, sacchi a pelo si. Sacco biodegradabile, sacco spesa, sacco termico no.

Restituisci ESATTAMENTE e SOLO un array JSON in questo formato (nessun blocco markdown, nessun backtick):
[
  {"name": "Latte Intero", "quantity": 1, "category": "Latticini"}
]
''');
    final imagePart = DataPart('image/jpeg', bytes);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      String responseText = response.text ?? "[]";
      // Pulizia forzata
      responseText =
          responseText.replaceAll("```json", "").replaceAll("```", "").trim();

      final List<dynamic> jsonList = jsonDecode(responseText);

      List<ItemModel> scannedItems = jsonList.map((item) {
        return ItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              item['name'].toString().hashCode.toString(),
          name: item['name'],
          quantity: item['quantity'],
          category: item['category'],
          isPantry: true,
        );
      }).toList();

      return scannedItems;
    } catch (e) {
      throw Exception("Errore durante l'analisi Gemini: $e");
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
