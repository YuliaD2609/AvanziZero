import 'dart:math';
import '../models/app_state.dart';

class LocalReceiptParser {
  // Dizionario massiccio per il Fuzzy Matching
  static final Map<String, Map<String, String>> _productDictionary = {
    // Frutta & Verdura
    'mela': {'name': 'Mela', 'category': 'Frutta & Verdura'},
    'mele': {'name': 'Mela', 'category': 'Frutta & Verdura'},
    'banana': {'name': 'Banana', 'category': 'Frutta & Verdura'},
    'pomodoro': {'name': 'Pomodoro', 'category': 'Frutta & Verdura'},
    'pomodori': {'name': 'Pomodoro', 'category': 'Frutta & Verdura'},
    'insalata': {'name': 'Insalata', 'category': 'Frutta & Verdura'},
    'patata': {'name': 'Patate', 'category': 'Frutta & Verdura'},
    'patate': {'name': 'Patate', 'category': 'Frutta & Verdura'},
    'cipolla': {'name': 'Cipolla', 'category': 'Frutta & Verdura'},
    'carote': {'name': 'Carote', 'category': 'Frutta & Verdura'},
    'zucchine': {'name': 'Zucchine', 'category': 'Frutta & Verdura'},
    'limone': {'name': 'Limone', 'category': 'Frutta & Verdura'},
    'pesca': {'name': 'Pesca', 'category': 'Frutta & Verdura'},
    'uva': {'name': 'Uva', 'category': 'Frutta & Verdura'},
    'fragole': {'name': 'Fragole', 'category': 'Frutta & Verdura'},
    'melanzane': {'name': 'Melanzane', 'category': 'Frutta & Verdura'},
    'peperoni': {'name': 'Peperoni', 'category': 'Frutta & Verdura'},
    'aglio': {'name': 'Aglio', 'category': 'Frutta & Verdura'},
    'broccoli': {'name': 'Broccoli', 'category': 'Frutta & Verdura'},
    'spinaci': {'name': 'Spinaci', 'category': 'Frutta & Verdura'},
    'arance': {'name': 'Arance', 'category': 'Frutta & Verdura'},
    'mandarini': {'name': 'Mandarini', 'category': 'Frutta & Verdura'},
    'radicchio': {'name': 'Radicchio', 'category': 'Frutta & Verdura'},
    'kiwi': {'name': 'Kiwi', 'category': 'Frutta & Verdura'},
    'finocchi': {'name': 'Finocchi', 'category': 'Frutta & Verdura'},
    'cetrioli': {'name': 'Cetrioli', 'category': 'Frutta & Verdura'},

    // Latticini
    'latte': {'name': 'Latte', 'category': 'Latticini'},
    'mozzarella': {'name': 'Mozzarella', 'category': 'Latticini'},
    'burro': {'name': 'Burro', 'category': 'Latticini'},
    'yogurt': {'name': 'Yogurt', 'category': 'Latticini'},
    'formaggio': {'name': 'Formaggio', 'category': 'Latticini'},
    'parmigiano': {'name': 'Parmigiano', 'category': 'Latticini'},
    'grana': {'name': 'Grana', 'category': 'Latticini'},
    'uova': {'name': 'Uova', 'category': 'Latticini'},
    'panna': {'name': 'Panna', 'category': 'Latticini'},
    'stracchino': {'name': 'Stracchino', 'category': 'Latticini'},
    'ricotta': {'name': 'Ricotta', 'category': 'Latticini'},
    'sottiletta': {'name': 'Sottilette', 'category': 'Latticini'},
    'sottilette': {'name': 'Sottilette', 'category': 'Latticini'},
    'mascarpone': {'name': 'Mascarpone', 'category': 'Latticini'},
    'pecorino': {'name': 'Pecorino', 'category': 'Latticini'},
    'gorgonzola': {'name': 'Gorgonzola', 'category': 'Latticini'},
    'provolone': {'name': 'Provolone', 'category': 'Latticini'},

    // Carne & Pesce
    'pollo': {'name': 'Pollo', 'category': 'Carne & Pesce'},
    'manzo': {'name': 'Manzo', 'category': 'Carne & Pesce'},
    'maiale': {'name': 'Maiale', 'category': 'Carne & Pesce'},
    'carne': {'name': 'Carne', 'category': 'Carne & Pesce'},
    'salame': {'name': 'Salame', 'category': 'Carne & Pesce'},
    'prosciutto': {'name': 'Prosciutto', 'category': 'Carne & Pesce'},
    'tonno': {'name': 'Tonno', 'category': 'Carne & Pesce'},
    'salmone': {'name': 'Salmone', 'category': 'Carne & Pesce'},
    'pesce': {'name': 'Pesce', 'category': 'Carne & Pesce'},
    'hamburger': {'name': 'Hamburger', 'category': 'Carne & Pesce'},
    'wurstel': {'name': 'Wurstel', 'category': 'Carne & Pesce'},
    'mortadella': {'name': 'Mortadella', 'category': 'Carne & Pesce'},
    'pancetta': {'name': 'Pancetta', 'category': 'Carne & Pesce'},
    'salsiccia': {'name': 'Salsiccia', 'category': 'Carne & Pesce'},
    'bresaola': {'name': 'Bresaola', 'category': 'Carne & Pesce'},
    'tacchino': {'name': 'Tacchino', 'category': 'Carne & Pesce'},
    'sgombro': {'name': 'Sgombro', 'category': 'Carne & Pesce'},
    'gamberi': {'name': 'Gamberi', 'category': 'Carne & Pesce'},
    'calamari': {'name': 'Calamari', 'category': 'Carne & Pesce'},

    // Secco, Pasta, Conserve & Legumi
    'pasta': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'spaghetti': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'penne': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'fusilli': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'maccheroni': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'riso': {'name': 'Riso', 'category': 'Secco & Pasta'},
    'pane': {'name': 'Pane', 'category': 'Secco & Pasta'},
    'piadina': {'name': 'Piadina', 'category': 'Secco & Pasta'},
    'sfoglia': {'name': 'Piadina', 'category': 'Secco & Pasta'},
    'farina': {'name': 'Farina', 'category': 'Secco & Pasta'},
    'zucchero': {'name': 'Zucchero', 'category': 'Secco & Pasta'},
    'sale': {'name': 'Sale', 'category': 'Secco & Pasta'},
    'olio': {'name': 'Olio', 'category': 'Secco & Pasta'},
    'aceto': {'name': 'Aceto', 'category': 'Secco & Pasta'},
    'biscotti': {'name': 'Biscotti', 'category': 'Secco & Pasta'},
    'cereali': {'name': 'Cereali', 'category': 'Secco & Pasta'},
    'caffe': {'name': 'Caffè', 'category': 'Secco & Pasta'},
    'nutella': {'name': 'Nutella', 'category': 'Secco & Pasta'},
    'marmellata': {'name': 'Marmellata', 'category': 'Secco & Pasta'},
    'fette biscottate': {'name': 'Fette Biscottate', 'category': 'Secco & Pasta'},
    'crackers': {'name': 'Crackers', 'category': 'Secco & Pasta'},
    'grissini': {'name': 'Grissini', 'category': 'Secco & Pasta'},
    'passata': {'name': 'Passata di Pomodoro', 'category': 'Secco & Pasta'},
    'pesto': {'name': 'Pesto', 'category': 'Secco & Pasta'},
    'maionese': {'name': 'Maionese', 'category': 'Secco & Pasta'},
    'ketchup': {'name': 'Ketchup', 'category': 'Secco & Pasta'},
    'fagioli': {'name': 'Fagioli', 'category': 'Secco & Pasta'},
    'ceci': {'name': 'Ceci', 'category': 'Secco & Pasta'},
    'piselli': {'name': 'Piselli', 'category': 'Secco & Pasta'},
    'lenticchie': {'name': 'Lenticchie', 'category': 'Secco & Pasta'},
    'lent': {'name': 'Lenticchie', 'category': 'Secco & Pasta'},
    'patatine': {'name': 'Patatine', 'category': 'Snack & Dolci'},
    'cioccolato': {'name': 'Cioccolato', 'category': 'Snack & Dolci'},
    'merendine': {'name': 'Merendine', 'category': 'Snack & Dolci'},
    'croissant': {'name': 'Croissant', 'category': 'Snack & Dolci'},

    // Bevande
    'acqua': {'name': 'Acqua', 'category': 'Bevande'},
    'coca': {'name': 'Coca Cola', 'category': 'Bevande'},
    'vino': {'name': 'Vino', 'category': 'Bevande'},
    'birra': {'name': 'Birra', 'category': 'Bevande'},
    'succo': {'name': 'Succo di frutta', 'category': 'Bevande'},
    'fanta': {'name': 'Fanta', 'category': 'Bevande'},
    'sprite': {'name': 'Sprite', 'category': 'Bevande'},
    'estathe': {'name': 'Estathe', 'category': 'Bevande'},
    'the': {'name': 'Tè', 'category': 'Bevande'},
    'amaro': {'name': 'Amaro', 'category': 'Bevande'},
    'spumante': {'name': 'Spumante', 'category': 'Bevande'},

    // Igiene e Casa
    'carta igienica': {'name': 'Carta Igienica', 'category': 'Igiene Casa'},
    'detersivo': {'name': 'Detersivo', 'category': 'Igiene Casa'},
    'sapone': {'name': 'Sapone', 'category': 'Igiene Casa'},
    'shampoo': {'name': 'Shampoo', 'category': 'Igiene Casa'},
    'dentifricio': {'name': 'Dentifricio', 'category': 'Igiene Casa'},
    'spugna': {'name': 'Spugna', 'category': 'Igiene Casa'},
    'scottex': {'name': 'Carta Casa', 'category': 'Igiene Casa'},
    'bagnoschiuma': {'name': 'Bagnoschiuma', 'category': 'Igiene Casa'},
    'sgrassatore': {'name': 'Sgrassatore', 'category': 'Igiene Casa'},
    'candeggina': {'name': 'Candeggina', 'category': 'Igiene Casa'},
    'ammorbidente': {'name': 'Ammorbidente', 'category': 'Igiene Casa'},
    'deodorante': {'name': 'Deodorante', 'category': 'Igiene Personale'},
    'pannolini': {'name': 'Pannolini', 'category': 'Igiene Personale'},
    'salvaslip': {'name': 'Salvaslip', 'category': 'Igiene Personale'},
    'assorbenti': {'name': 'Assorbenti', 'category': 'Igiene Personale'},
    'pellicola': {'name': 'Pellicola', 'category': 'Igiene Casa'},
    'alluminio': {'name': 'Alluminio', 'category': 'Igiene Casa'},
    'carta forno': {'name': 'Carta Forno', 'category': 'Igiene Casa'},
  };

  // Parole spazzatura OCR e marchi da cui rifuggire
  static final List<String> _garbageKeywords = [
    'totale', 'resto', 'contanti', 'bancomat', 'carta', 'euro', 'iva',
    'scontrino', 'reparto', 'sconto', 'pagamento', 'importo', 'sacchetto',
    'eur', 'piva', 'via', 'telefono', 'tel', 'grazie', 'arrivederci',
    'cassa', 'pos', 'transazione', 'bio', 'it', 'prec',
    'vverdeb', 'loriana', 'coop', 'maxi', 'conad', 'esselunga', 'pam', 'lidl',
    'eurospin', 'carrefour', 'md', 'penny', 'aldi', 'crai', 'despar', 'iper',
    'ipercoop', 'famila', 'tigros', 'unes', 'panorama', 'il gigante', 'deco',
    'basko', 'sisa', 'todis', 'tuodi', 'incoop', 'offerta', 'promozione', 'promo',
    'punti', 'fidaty', 'fidelita', 'soci', 'socio'
  ];

  /// Calcola la distanza di Levenshtein tra due stringhe (algoritmo matematico puro)
  static int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.filled(b.length + 1, 0);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  /// Restituisce un punteggio di similarità da 0.0 a 1.0
  static double _similarityScore(String a, String b) {
    int maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    int distance = _levenshteinDistance(a, b);
    return 1.0 - (distance / maxLen);
  }

  static List<ItemModel> parseReceiptText(String rawText) {
    List<ItemModel> extractedItems = [];
    List<String> lines = rawText.split('\n');

    for (String line in lines) {
      String cleanLine = line.toLowerCase().trim();
      if (cleanLine.length < 3) continue;

      // 1. Filtraggio Garbage Totale (Riga interamente da scartare)
      bool isGarbageLine = false;
      for (String garbage in ['sconto', 'totale', 'resto', 'contanti', 'bancomat', 'carta', 'pagamento', 'sacchetto', 'transazione', 'cassa', 'iva']) {
        if (cleanLine.contains(garbage)) {
          isGarbageLine = true;
          break;
        }
      }
      if (isGarbageLine) continue;

      if (RegExp(r'^[\d\s\W]+$').hasMatch(cleanLine)) continue;

      // 2. Pulizia Prezzi, IVA e Codici di Calibro (es. 14-2, 7585) dal testo puro
      // Rimuove i prezzi alla fine seguiti da una lettera IVA (es. "3,12 B" o "8,99 D")
      String textWithoutPrice = cleanLine
          .replaceAll(RegExp(r'\s*\d+[,\.]\d{2}\s*(€|eur|e)?\s*[a-zA-Z]?\s*$'), '')
          .trim();
          
      // Rimuove pesi e calibri (es. 14-2, 75-85, 250g, 400g)
      textWithoutPrice = textWithoutPrice
          .replaceAll(RegExp(r'\b\d+-\d+\b'), '')
          .replaceAll(RegExp(r'\b\d{4,}\b'), '') // Rimuove numeri grossi come 7585
          .replaceAll(RegExp(r'\b\d+\s*(g|kg|ml|l)\b'), '')
          .trim();

      // 3. Estrazione Quantità (dopo aver rimosso calibri e codici)
      int quantity = _extractQuantity(textWithoutPrice);

      String productNameRaw = textWithoutPrice
          .replaceAll(RegExp(r'\b\d+[\s]*[xX]?\b'), '') // Rimuove la quantità estratta dal nome
          .trim();

      // Rimuove garbage words specifiche dal nome prodotto (es. 'coop', 'it', 'bio')
      for (String garbage in _garbageKeywords) {
        productNameRaw = productNameRaw.replaceAll(RegExp(r'\b' + garbage + r'\b'), ' ').trim();
      }

      productNameRaw =
          productNameRaw.replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

      if (productNameRaw.isEmpty || productNameRaw.length < 3) continue;

      // 4. Intelligenza Artificiale Matematica (Fuzzy Matching)
      String finalName = productNameRaw;
      String finalCategory = 'Altro';

      double bestSimilarity = 0.0;
      String bestMatchKey = '';

      // Confrontiamo la riga "sporca" con tutte le parole del dizionario
      for (String dictKey in _productDictionary.keys) {
        // Splittiamo la riga in parole per trovare match parziali (es. "LATTE ARBOREA" -> "latte")
        List<String> words = productNameRaw.split(' ');
        for (String word in words) {
          if (word.length < 3) continue; // Ignoriamo articoli e preposizioni
          double sim = _similarityScore(word, dictKey);
          if (sim > bestSimilarity) {
            bestSimilarity = sim;
            bestMatchKey = dictKey;
          }
        }
      }

      // Se c'è una similarità > 70% consideriamo la parola corretta!
      if (bestSimilarity >= 0.70) {
        finalName = _productDictionary[bestMatchKey]!['name']!;
        finalCategory = _productDictionary[bestMatchKey]!['category']!;
      } else {
        // Se non trova niente, capitalizza il nome originale senza perderlo
        finalName = finalName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
            .join(' ')
            .trim();
      }

      extractedItems.add(ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            finalName.hashCode.toString(),
        name: finalName,
        quantity: quantity,
        category: finalCategory,
        isPantry: true,
      ));
    }

    // 5. Raggruppamento duplicati
    Map<String, ItemModel> groupedItems = {};
    for (var item in extractedItems) {
      if (groupedItems.containsKey(item.name)) {
        var existing = groupedItems[item.name]!;
        groupedItems[item.name] = ItemModel(
            id: existing.id,
            name: existing.name,
            expireDate: existing.expireDate,
            quantity: existing.quantity + item.quantity,
            category: existing.category,
            isPantry: true);
      } else {
        groupedItems[item.name] = item;
      }
    }

    return groupedItems.values.toList();
  }

  static int _extractQuantity(String text) {
    RegExp regex = RegExp(r'\b(\d+)[\s]*[xX]?\b');
    var match = regex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    return 1;
  }
}
