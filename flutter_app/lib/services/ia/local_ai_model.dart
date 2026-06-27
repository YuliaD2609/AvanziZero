import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../../models/app_state.dart';

class LocalPredictiveModel {
  // Analizza storico e dispensa
  static Map<String, List<ItemModel>> predict(
      List<ItemModel> pantryItems,
      List<ItemModel> shoppingItems,
      List<Map<String, dynamic>> consumptionHistory,
      int groupSize) {
    List<ItemModel> scarcity = [];
    List<ItemModel> expiring = [];

    // Crea set nomi spesa
    Set<String> shoppingNames =
        shoppingItems.map((s) => s.name.toLowerCase().trim()).toSet();

    // Gestisce scadenze
    for (var item in pantryItems) {
      if (item.urgencyLevel == 2 &&
          !shoppingNames.contains(item.name.toLowerCase().trim())) {
        expiring.add(ItemModel(
          id: '',
          name: item.name,
          category: item.category,
        ));
      }
    }

    // Analizza storico consumi
    Map<String, double> consumptionScores = {};
    Map<String, String> itemCategories = {}; // Ricorda categoria

    for (var log in consumptionHistory) {
      String name = (log['name'] ?? '').toString();
      if (name.isEmpty) continue;

      int qty = (log['quantity'] ?? 1) as int;

      // Calcola giorni trascorsi
      int daysAgo = 0;
      if (log['timestamp'] != null) {
        try {
          DateTime date = (log['timestamp'] as Timestamp).toDate();
          daysAgo = DateTime.now().difference(date).inDays;
        } catch (e) {
          // Ignora errori timestamp
        }
      }

      // Calcola decadimento temporale
      double decayWeight = math.exp(-0.05 * daysAgo);
      double logScore = qty * decayWeight;

      String nameKey = name.toLowerCase().trim();
      consumptionScores[nameKey] =
          (consumptionScores[nameKey] ?? 0.0) + logScore;

      // Deduce categoria
      var match =
          pantryItems.where((i) => i.name.toLowerCase().trim() == nameKey);
      if (match.isNotEmpty) {
        itemCategories[nameKey] = match.first.category;
      } else {
        itemCategories[nameKey] = 'Altro';
      }
    }

    // Calcola scarsità
    // Valuta punteggi consumo
    consumptionScores.forEach((nameKey, score) {
      if (shoppingNames.contains(nameKey)) return; // Salta prodotti già in spesa

      // Cerca quantità in dispensa
      var pantryMatch =
          pantryItems.where((i) => i.name.toLowerCase().trim() == nameKey);
      int currentQty = pantryMatch.isNotEmpty ? pantryMatch.first.quantity : 0;
      String category = itemCategories[nameKey] ?? 'Altro';
      String originalName =
          pantryMatch.isNotEmpty ? pantryMatch.first.name : nameKey;

      // Suggerisce se esaurito o in esaurimento

      if (currentQty == 0) {
        // Prodotto esaurito
        scarcity.add(ItemModel(
            id: '',
            name: originalName,
            category: category));
      } else {
        double scarcityRatio = score / currentQty;

        // Controlla consumo e rimanenza assoluta
        if (scarcityRatio > 0.8 || (currentQty <= 2 && score >= 1.0)) {
          // Previene duplicati
          bool isExpiring =
              expiring.any((e) => e.name.toLowerCase().trim() == nameKey);
          if (!isExpiring) {
            scarcity.add(ItemModel(
                id: '',
                name: originalName,
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
