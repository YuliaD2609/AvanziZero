import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/app_state.dart';

class LocalPredictiveModel {
  /// Analizza dispensa e storico e restituisce suggerimenti intelligenti divisi in 'scarcity' e 'expiring'
  static Map<String, List<ItemModel>> predict(
      List<ItemModel> pantryItems,
      List<ItemModel> shoppingItems,
      List<Map<String, dynamic>> consumptionHistory,
      int groupSize) {
    List<ItemModel> scarcity = [];
    List<ItemModel> expiring = [];

    // Set veloce dei nomi in lista spesa per escluderli
    Set<String> shoppingNames =
        shoppingItems.map((s) => s.name.toLowerCase().trim()).toSet();

    // 1. GESTIONE SCADENZE (urgencyLevel == 2)
    for (var item in pantryItems) {
      if (item.urgencyLevel == 2 &&
          !shoppingNames.contains(item.name.toLowerCase().trim())) {
        expiring.add(ItemModel(
          id: '',
          name: item.name,
          expireDate: 'Data: N/A',
          quantity: 1,
          category: item.category,
        ));
      }
    }

    // 2. ANALISI STORICO CON TIME DECAY
    Map<String, double> consumptionScores = {};
    Map<String, String> itemCategories = {}; // Per ricordare la categoria

    for (var log in consumptionHistory) {
      String name = (log['name'] ?? '').toString();
      if (name.isEmpty) continue;

      int qty = (log['quantity'] ?? 1) as int;

      // Calcolo giorni trascorsi per il decadimento temporale
      int daysAgo = 0;
      if (log['timestamp'] != null) {
        try {
          DateTime date = (log['timestamp'] as Timestamp).toDate();
          daysAgo = DateTime.now().difference(date).inDays;
        } catch (e) {
          // Fallback se timestamp non parsabile
        }
      }

      // Decadimento: un consumo recente vale il 100%, un consumo vecchio perde peso progressivamente
      double decayWeight = math.exp(-0.05 * daysAgo);
      double logScore = qty * decayWeight;

      String nameKey = name.toLowerCase().trim();
      consumptionScores[nameKey] =
          (consumptionScores[nameKey] ?? 0.0) + logScore;

      // Cerchiamo di dedurre la categoria basandoci sulla dispensa attuale se esiste
      var match =
          pantryItems.where((i) => i.name.toLowerCase().trim() == nameKey);
      if (match.isNotEmpty) {
        itemCategories[nameKey] = match.first.category;
      } else {
        itemCategories[nameKey] = 'Altro';
      }
    }

    // 3. CALCOLO DELLA SCARSITÀ
    // Iteriamo sui punteggi di consumo. Più il punteggio è alto, più il prodotto viene usato spesso.
    consumptionScores.forEach((nameKey, score) {
      if (shoppingNames.contains(nameKey)) return; // Già nella spesa

      // Cerchiamo la quantità attuale in dispensa
      var pantryMatch =
          pantryItems.where((i) => i.name.toLowerCase().trim() == nameKey);
      int currentQty = pantryMatch.isNotEmpty ? pantryMatch.first.quantity : 0;
      String category = itemCategories[nameKey] ?? 'Altro';
      String originalName =
          pantryMatch.isNotEmpty ? pantryMatch.first.name : nameKey;

      // Se il prodotto è completamente esaurito (qty = 0) ma ha uno storico di consumo (> 0), suggeriscilo!
      // Se il prodotto è in dispensa, valuta il rapporto tra punteggio di consumo e quantità rimanente.
      // Esempio: se score = 3.0 e rimangono solo 2 elementi, ratio = 1.5 (Alto rischio scarsità)
      // Un prodotto base per persona (groupSize) incide sulla tolleranza.

      if (currentQty == 0) {
        // Esaurito ma consumato in passato
        scarcity.add(ItemModel(
            id: '',
            name: originalName,
            expireDate: 'Data: N/A',
            quantity: 1,
            category: category));
      } else {
        double scarcityRatio = score / currentQty;

        // Se il consumo superato/pesato è maggiore o uguale alla quantità che ci rimane
        // O se ne rimangono pochi in senso assoluto rispetto al gruppo
        if (scarcityRatio > 0.8 || (currentQty <= 2 && score >= 1.0)) {
          // Previene duplicati se è già in expiring
          bool isExpiring =
              expiring.any((e) => e.name.toLowerCase().trim() == nameKey);
          if (!isExpiring) {
            scarcity.add(ItemModel(
                id: '',
                name: originalName,
                expireDate: 'Data: N/A',
                quantity: 1,
                category: category));
          }
        }
      }
    });

    return {
      'scarcity': scarcity,
      'expiring': expiring,
    };
  }
}
