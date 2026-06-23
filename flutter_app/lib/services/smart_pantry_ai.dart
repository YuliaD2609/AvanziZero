import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state.dart';

class AIPrediction {
  final String nomeProdotto;
  final int quantitaSuggerita;
  final String motivoAggiunta;
  final int confidenzaPercentuale;
  final bool autoAdd; // FR6.7: Flag per inserimento automatico

  AIPrediction({
    required this.nomeProdotto,
    required this.quantitaSuggerita,
    required this.motivoAggiunta,
    required this.confidenzaPercentuale,
    this.autoAdd = false,
  });
}

class SmartPantryAI {
  /// Motore predittivo 100% locale per SmartPantry
  static List<AIPrediction> predict(
    List<ItemModel> pantryItems,
    List<ItemModel> shoppingItems,
    List<Map<String, dynamic>> consumptionHistory,
    int groupSize,
    Map<String, Map<String, int>> aiFeedback,
  ) {
    List<AIPrediction> suggestions = [];

    // Set di elementi già presenti nella lista della spesa per evitare doppioni
    Set<String> shoppingNames =
        shoppingItems.map((s) => s.name.toLowerCase().trim()).toSet();

    // Raggruppare la history per prodotto
    Map<String, List<Map<String, dynamic>>> historyByName = {};
    for (var log in consumptionHistory) {
      String name = (log['name'] ?? '').toString().toLowerCase().trim();
      if (name.isEmpty) continue;
      if (!historyByName.containsKey(name)) {
        historyByName[name] = [];
      }
      historyByName[name]!.add(log);
    }

    // Costruiamo una mappa rapida della dispensa
    Map<String, List<ItemModel>> pantryByName = {};
    for (var item in pantryItems) {
      String name = item.name.toLowerCase().trim();
      if (!pantryByName.containsKey(name)) {
        pantryByName[name] = [];
      }
      pantryByName[name]!.add(item);
    }

    // --- ANALISI STORICO (Consumption Rate, Expiration Buffer, Depletion Threshold) ---
    historyByName.forEach((nameKey, logs) {
      if (shoppingNames.contains(nameKey)) return;

      // Estraiamo i timestamp validi
      List<DateTime> purchaseDates = [];
      int totalQtyHistoricallyAdded = 0;

      for (var log in logs) {
        if (log['timestamp'] != null) {
          try {
            purchaseDates.add((log['timestamp'] as Timestamp).toDate());
            totalQtyHistoricallyAdded += (log['quantity'] as int?) ?? 1;
          } catch (e) {
            // Ignora errori di parsing del timestamp
          }
        }
      }

      // Ordiniamo le date per calcolare le frequenze
      purchaseDates.sort((a, b) => a.compareTo(b));

      // 1. Analisi Frequenza (Consumption Rate)
      double avgDaysBetweenPurchases = -1;
      if (purchaseDates.length > 1) {
        int totalDays = 0;
        for (int i = 1; i < purchaseDates.length; i++) {
          totalDays += purchaseDates[i].difference(purchaseDates[i - 1]).inDays;
        }
        avgDaysBetweenPurchases = totalDays / (purchaseDates.length - 1);
      }

      // Dispensa Attuale
      var pItems = pantryByName[nameKey] ?? [];
      int currentQty = pItems.fold(0, (sum, item) => sum + item.quantity);
      String originalName = pItems.isNotEmpty ? pItems.first.name : (logs.first['name'] ?? nameKey);

      bool triggered = false;
      String motivo = "";
      int confidenza = 50; // Base
      int qtySuggerita = 1; // Default
      
      // La quantità media acquistata storicamente
      if (logs.isNotEmpty && totalQtyHistoricallyAdded > 0) {
        qtySuggerita = (totalQtyHistoricallyAdded / logs.length).ceil();
        if (qtySuggerita < 1) qtySuggerita = 1;
      }

      // Analisi Scadenze Imminenti (Condizione B)
      // Mettiamo in evidenza se in dispensa c'è un prodotto in scadenza.
      // Siccome non salviamo il "Expiration Buffer" nel log attualmente, usiamo una soglia intelligente:
      // Se il prodotto scade entro 3 giorni ed è un prodotto che si consuma spesso, suggeriamolo.
      bool isExpiringImminently = false;
      int minDaysToExpiration = 999;
      for (var p in pItems) {
        if (p.urgencyLevel >= 1) { // Giallo o Rosso (<= 7 giorni)
          isExpiringImminently = true;
          if (p.parsedExpireDate != null) {
            int diff = p.parsedExpireDate!.difference(DateTime.now()).inDays;
            if (diff < minDaysToExpiration) minDaysToExpiration = diff;
          }
        }
      }

      // Se non abbiamo un Expiration Buffer storico, assumiamo che <= 3 giorni sia il buffer.
      int expirationBuffer = 3; 

      if (isExpiringImminently && minDaysToExpiration <= expirationBuffer) {
        triggered = true;
        if (minDaysToExpiration < 0) {
          motivo = "Prodotto scaduto da ${minDaysToExpiration.abs()} giorni";
        } else {
          motivo = "Scadenza imminente (Scade tra $minDaysToExpiration giorni)";
        }
        // Più log abbiamo, più alta è la confidenza
        confidenza = mathMin(100, 70 + (logs.length * 5));
      }

      // Condizione A: Soglia di Riordino (Depletion Threshold)
      // Siccome non abbiamo il livello esatto di giacenza al momento dell'acquisto salvato nel log,
      // deduciamo la soglia in base alla dimensione del gruppo.
      int depletionThreshold = groupSize > 2 ? 2 : 1; 
      if (!triggered && currentQty > 0 && currentQty <= depletionThreshold) {
        // È quasi esaurito. Verifichiamo se lo compra spesso.
        if (avgDaysBetweenPurchases != -1 && avgDaysBetweenPurchases <= 14) {
          triggered = true;
          motivo = "Esaurimento imminente (Soglia: $currentQty rimanenti)";
          confidenza = mathMin(100, 60 + (logs.length * 5));
        }
      }

      // FR6.6: Se rifiutato troppe volte, blocca il suggerimento
      int acceptCount = aiFeedback[nameKey]?['acceptCount'] ?? 0;
      int rejectCount = aiFeedback[nameKey]?['rejectCount'] ?? 0;

      if (rejectCount >= 3) {
        return; 
      }

      // Condizione C: Frequenza di Acquisto superata ed è esaurito
      if (!triggered && currentQty == 0) {
        if (purchaseDates.isNotEmpty) {
          int daysSinceLastPurchase = DateTime.now().difference(purchaseDates.last).inDays;
          if (avgDaysBetweenPurchases != -1 && daysSinceLastPurchase >= (avgDaysBetweenPurchases * 0.8)) {
            // È passato l'80% del tempo medio tra due acquisti, ed è finito.
            triggered = true;
            motivo = "Frequenza di acquisto (Comprato ogni ~${avgDaysBetweenPurchases.toStringAsFixed(0)} giorni)";
            confidenza = mathMin(100, 75 + (logs.length * 3));
          } else if (avgDaysBetweenPurchases == -1 && logs.length >= 1) {
            // È stato comprato almeno una volta ma è finito
             triggered = true;
             motivo = "Esaurimento imminente (Soglia: 0 rimanenti)";
             confidenza = 65;
          }
        }
      }

      if (triggered) {
        // FR6.6: Usa accettazione/rifiuto come feedback per affinare il modello predittivo
        confidenza -= (rejectCount * 15);
        confidenza += (acceptCount * 10);
        confidenza = mathMin(100, confidenza);

        if (confidenza > 0) {
          suggestions.add(AIPrediction(
            nomeProdotto: originalName,
            quantitaSuggerita: qtySuggerita,
            motivoAggiunta: motivo,
            confidenzaPercentuale: confidenza,
            autoAdd: acceptCount > 3, // FR6.7: Inserimento automatico se accettato > 3 volte
          ));
        }
      }
    });

    // Ordiniamo per confidenza decrescente
    suggestions.sort((a, b) => b.confidenzaPercentuale.compareTo(a.confidenzaPercentuale));

    return suggestions;
  }

  static int mathMin(int a, int b) {
    return a < b ? a : b;
  }
}
