import '../models/app_state.dart';

class LocalReceiptParser {
  // Dizionario esteso per mappare parole chiave trovate nello scontrino a prodotti reali e categorie.
  static final Map<String, Map<String, String>> _productDictionary = {
    // Frutta & Verdura
    'mela': {'name': 'Mela', 'category': 'Frutta & Verdura'},
    'mele': {'name': 'Mela', 'category': 'Frutta & Verdura'},
    'banan': {'name': 'Banana', 'category': 'Frutta & Verdura'},
    'pomodor': {'name': 'Pomodoro', 'category': 'Frutta & Verdura'},
    'insalat': {'name': 'Insalata', 'category': 'Frutta & Verdura'},
    'patat': {'name': 'Patate', 'category': 'Frutta & Verdura'},
    'cipoll': {'name': 'Cipolla', 'category': 'Frutta & Verdura'},
    'carot': {'name': 'Carota', 'category': 'Frutta & Verdura'},
    'zucchine': {'name': 'Zucchina', 'category': 'Frutta & Verdura'},
    'limon': {'name': 'Limone', 'category': 'Frutta & Verdura'},
    'pesch': {'name': 'Pesca', 'category': 'Frutta & Verdura'},

    // Latticini
    'latte': {'name': 'Latte', 'category': 'Latticini'},
    'mozzarella': {'name': 'Mozzarella', 'category': 'Latticini'},
    'burro': {'name': 'Burro', 'category': 'Latticini'},
    'yogurt': {'name': 'Yogurt', 'category': 'Latticini'},
    'formaggio': {'name': 'Formaggio', 'category': 'Latticini'},
    'parmigiano': {'name': 'Parmigiano', 'category': 'Latticini'},
    'grana': {'name': 'Grana', 'category': 'Latticini'},
    'uova': {'name': 'Uova', 'category': 'Latticini'}, // Uova spesso nei latticini

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

    // Secco & Pasta
    'pasta': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'spaghetti': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'penne': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'riso': {'name': 'Riso', 'category': 'Secco & Pasta'},
    'pane': {'name': 'Pane', 'category': 'Secco & Pasta'},
    'farina': {'name': 'Farina', 'category': 'Secco & Pasta'},
    'zucchero': {'name': 'Zucchero', 'category': 'Secco & Pasta'},
    'sale': {'name': 'Sale', 'category': 'Secco & Pasta'},
    'olio': {'name': 'Olio', 'category': 'Secco & Pasta'},
    'aceto': {'name': 'Aceto', 'category': 'Secco & Pasta'},
    'biscotti': {'name': 'Biscotti', 'category': 'Secco & Pasta'},
    'cereali': {'name': 'Cereali', 'category': 'Secco & Pasta'},
    'caffe': {'name': 'Caffè', 'category': 'Secco & Pasta'},

    // Bevande
    'acqua': {'name': 'Acqua', 'category': 'Bevande'},
    'coca': {'name': 'Coca Cola', 'category': 'Bevande'},
    'vino': {'name': 'Vino', 'category': 'Bevande'},
    'birra': {'name': 'Birra', 'category': 'Bevande'},
    'succo': {'name': 'Succo di frutta', 'category': 'Bevande'},
    'fanta': {'name': 'Fanta', 'category': 'Bevande'},
    'the': {'name': 'Tè', 'category': 'Bevande'},

    // Igiene Casa
    'carta igienica': {'name': 'Carta Igienica', 'category': 'Igiene Casa'},
    'detersivo': {'name': 'Detersivo', 'category': 'Igiene Casa'},
    'sapone': {'name': 'Sapone', 'category': 'Igiene Casa'},
    'shampoo': {'name': 'Shampoo', 'category': 'Igiene Casa'},
    'dentifricio': {'name': 'Dentifricio', 'category': 'Igiene Casa'},
    'spugn': {'name': 'Spugna', 'category': 'Igiene Casa'},
    'scottex': {'name': 'Carta Casa', 'category': 'Igiene Casa'},
  };

  // Parole chiave "spazzatura" da ignorare sempre
  static final List<String> _garbageKeywords = [
    'totale', 'resto', 'contanti', 'bancomat', 'carta', 'euro', 'iva', 'scontrino', 'reparto', 'sconto', 'pagamento', 'importo', 'sacchetto'
  ];

  /// Analizza il testo raw estratto dall'OCR e ritorna una lista di prodotti.
  static List<ItemModel> parseReceiptText(String rawText) {
    List<ItemModel> extractedItems = [];
    
    // Dividiamo il testo in righe e lo puliamo
    List<String> lines = rawText.split('\n');

    for (String line in lines) {
      String cleanLine = line.toLowerCase().trim();
      if (cleanLine.isEmpty) continue;

      // Saltiamo le righe con parole spazzatura tipiche dello scontrino
      bool isGarbage = false;
      for (String garbage in _garbageKeywords) {
        if (cleanLine.contains(garbage)) {
          isGarbage = true;
          break;
        }
      }
      if (isGarbage) continue;

      // Cerchiamo di trovare un match nel nostro dizionario
      Map<String, String>? matchedProduct;
      for (String key in _productDictionary.keys) {
        // Se la riga contiene la parola chiave del dizionario
        if (cleanLine.contains(key)) {
          matchedProduct = _productDictionary[key];
          break;
        }
      }

      // Se troviamo un match, estraiamo la quantità (molto basilare: cerca se la riga inizia con un numero o ha un 'x')
      if (matchedProduct != null) {
        int quantity = _extractQuantity(cleanLine);
        
        extractedItems.add(ItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + matchedProduct['name'].toString().hashCode.toString(),
          name: matchedProduct['name']!,
          expireDate: 'Data: N/A', // Lo scontrino non dà la scadenza
          quantity: quantity,
          category: matchedProduct['category']!,
          isPantry: true, // Si assumono già acquistati e da mettere in dispensa
        ));
      }
    }

    // Raggruppiamo i duplicati (es. se trova due righe di "Acqua")
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
          isPantry: true
        );
      } else {
        groupedItems[item.name] = item;
      }
    }

    return groupedItems.values.toList();
  }

  /// Estrazione rudimentale della quantità da una stringa (es. "2x LATTE" o "3 BANANE")
  static int _extractQuantity(String text) {
    // Cerchiamo un numero all'inizio della riga o seguito da "x"
    RegExp regex = RegExp(r'\b(\d+)[\s]*[xX]?\b');
    var match = regex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    return 1;
  }
}
