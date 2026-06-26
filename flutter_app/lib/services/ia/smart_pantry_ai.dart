import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_state.dart';

class AIPrediction {
  final String nomeProdotto;
  final int quantitaSuggerita;
  final String motivoAggiunta;
  final int confidenzaPercentuale;
  final bool autoAdd; // Flag inserimento automatico

  AIPrediction({
    required this.nomeProdotto,
    required this.quantitaSuggerita,
    required this.motivoAggiunta,
    required this.confidenzaPercentuale,
    this.autoAdd = false,
  });
}

class SmartPantryAI {
  // Motore predittivo locale
  static List<AIPrediction> predict(
    List<ItemModel> pantryItems,
    List<ItemModel> shoppingItems,
    List<Map<String, dynamic>> consumptionHistory,
    int groupSize,
    Map<String, Map<String, int>> aiFeedback,
  ) {
    List<AIPrediction> suggestions = [];

    // Set elementi spesa
    Set<String> shoppingNames =
        shoppingItems.map((s) => s.name.toLowerCase().trim()).toSet();

    // Raggruppa storico
    Map<String, List<Map<String, dynamic>>> historyByName = {};
    for (var log in consumptionHistory) {
      String name = (log['name'] ?? '').toString().toLowerCase().trim();
      if (name.isEmpty) continue;
      if (!historyByName.containsKey(name)) {
        historyByName[name] = [];
      }
      historyByName[name]!.add(log);
    }

    // Crea mappa dispensa
    Map<String, List<ItemModel>> pantryByName = {};
    for (var item in pantryItems) {
      String name = item.name.toLowerCase().trim();
      if (!pantryByName.containsKey(name)) {
        pantryByName[name] = [];
      }
      pantryByName[name]!.add(item);
    }

    // Analizza storico
    historyByName.forEach((nameKey, logs) {
      if (shoppingNames.contains(nameKey)) return;

      // Estrae timestamp validi
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

      // Ordina date
      purchaseDates.sort((a, b) => a.compareTo(b));

      // Analizza frequenza
      double avgDaysBetweenPurchases = -1;
      if (purchaseDates.length > 1) {
        int totalDays = 0;
        for (int i = 1; i < purchaseDates.length; i++) {
          totalDays += purchaseDates[i].difference(purchaseDates[i - 1]).inDays;
        }
        avgDaysBetweenPurchases = totalDays / (purchaseDates.length - 1);
      }

      // Dispensa attuale
      var pItems = pantryByName[nameKey] ?? [];
      int currentQty = pItems.fold(0, (sum, item) => sum + item.quantity);
      String originalName = pItems.isNotEmpty ? pItems.first.name : (logs.first['name'] ?? nameKey);

      bool triggered = false;
      String motivo = "";
      int confidenza = 50; // Base
      int qtySuggerita = 1; // Default
      
      // Quantità media storica
      if (logs.isNotEmpty && totalQtyHistoricallyAdded > 0) {
        qtySuggerita = (totalQtyHistoricallyAdded / logs.length).ceil();
        if (qtySuggerita < 1) qtySuggerita = 1;
      }

      // Analizza scadenze imminenti
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

      // Definisce buffer scadenza
      int expirationBuffer = 3; 

      if (isExpiringImminently && minDaysToExpiration <= expirationBuffer) {
        triggered = true;
        if (minDaysToExpiration < 0) {
          motivo = "Prodotto scaduto da ${minDaysToExpiration.abs()} giorni";
        } else {
          motivo = "Scadenza imminente (Scade tra $minDaysToExpiration giorni)";
        }
        // Aumenta confidenza con log
        confidenza = mathMin(100, 70 + (logs.length * 5));
      }

      // Definisce soglia riordino
      int depletionThreshold = groupSize > 2 ? 2 : 1; 
      if (!triggered && currentQty > 0 && currentQty <= depletionThreshold) {
        // Controlla frequenza se in esaurimento
        if (avgDaysBetweenPurchases != -1 && avgDaysBetweenPurchases <= 14) {
          triggered = true;
          motivo = "Esaurimento imminente (Soglia: $currentQty rimanenti)";
          confidenza = mathMin(100, 60 + (logs.length * 5));
        }
      }

      // Blocca suggerimento se rifiutato
      int acceptCount = aiFeedback[nameKey]?['acceptCount'] ?? 0;
      int rejectCount = aiFeedback[nameKey]?['rejectCount'] ?? 0;

      if (rejectCount >= 3) {
        return; 
      }

      // Verifica esaurimento e frequenza
      if (!triggered && currentQty == 0) {
        if (purchaseDates.isNotEmpty) {
          int daysSinceLastPurchase = DateTime.now().difference(purchaseDates.last).inDays;
          if (avgDaysBetweenPurchases != -1 && daysSinceLastPurchase >= (avgDaysBetweenPurchases * 0.8)) {
            // Tempo acquisto superato
            triggered = true;
            motivo = "Frequenza di acquisto (Comprato ogni ~${avgDaysBetweenPurchases.toStringAsFixed(0)} giorni)";
            confidenza = mathMin(100, 75 + (logs.length * 3));
          } else if (avgDaysBetweenPurchases == -1 && logs.length >= 1) {
            // Esaurito dopo acquisto
             triggered = true;
             motivo = "Esaurimento imminente (Soglia: 0 rimanenti)";
             confidenza = 65;
          }
        }
      }

      if (triggered) {
        // Usa feedback per confidenza
        confidenza -= (rejectCount * 15);
        confidenza += (acceptCount * 10);
        confidenza = mathMin(100, confidenza);

        if (confidenza > 0) {
          suggestions.add(AIPrediction(
            nomeProdotto: originalName,
            quantitaSuggerita: qtySuggerita,
            motivoAggiunta: motivo,
            confidenzaPercentuale: confidenza,
            autoAdd: acceptCount > 3, // Inserimento automatico
          ));
        }
      }
    });

    // Ordina per confidenza
    suggestions.sort((a, b) => b.confidenzaPercentuale.compareTo(a.confidenzaPercentuale));

    return suggestions;
  }

  static int mathMin(int a, int b) {
    return a < b ? a : b;
  }
}
