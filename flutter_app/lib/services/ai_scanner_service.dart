import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_state.dart';

class AIScannerService {
  // ATTENZIONE: Questo è un approccio semplificato e leggero (Multimodal Gemini 1.5 Flash).
  // Sostituisci la stringa sottostante con la tua API Key ottenuta gratuitamente su https://aistudio.google.com/
  static const String _apiKey = "AIzaSyBjJwepLVHcvKm1F8W-_q8vCkSsQg0aAb4";

  static Future<List<ItemModel>> scanReceipt(XFile imageFile) async {
    if (_apiKey.isEmpty || _apiKey == "INSERISCI_QUI_LA_TUA_API_KEY") {
      throw Exception(
          "API Key mancante! Ottienila su https://aistudio.google.com/ e inseriscila in ai_scanner_service.dart");
    }

    // Usiamo il modello veloce e leggero di Google (multimodale nativo)
    // Aggiornato ai modelli del 2026
    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
    );

    final bytes = await imageFile.readAsBytes();

    // Prompt ottimizzato per estrarre direttamente i campi necessari per ItemModel
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
      // Pulizia forzata da eventuali formattazioni markdown che l'LLM potrebbe comunque inserire
      responseText =
          responseText.replaceAll("```json", "").replaceAll("```", "").trim();

      final List<dynamic> jsonList = jsonDecode(responseText);

      // Mappiamo i risultati del JSON nei nostri ItemModel
      List<ItemModel> scannedItems = jsonList.map((item) {
        return ItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              item['name'].toString().hashCode.toString(),
          name: item['name'] ?? 'Prodotto Sconosciuto',
          expireDate:
              'Scadenza: da verificare', // L'IA non può sempre sapere la scadenza dallo scontrino
          quantity: item['quantity'] ?? 1,
          category: item['category'] ?? 'Altro',
          isPantry:
              true, // L'utente ci ha chiesto di metterli direttamente in dispensa
        );
      }).toList();

      return scannedItems;
    } catch (e, stackTrace) {
      print("=========================================");
      print("❌ ERRORE CRITICO IA SCANNER");
      print("=========================================");
      print("Dettaglio Errore: $e");
      print("Stack Trace: $stackTrace");
      print("=========================================");
      throw Exception("Errore di elaborazione IA: $e");
    }
  }
}
