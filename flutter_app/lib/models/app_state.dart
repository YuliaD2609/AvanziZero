import 'package:flutter/material.dart';

class ItemModel {
  final String id;
  String name;
  String expireDate; // Formato testuale "gg/mm/aaaa" come da layout nativo
  int quantity;
  String category;
  bool isPantry;
  bool isShopping;
  bool isSuitcase;

  ItemModel({
    required this.id,
    required this.name,
    required this.expireDate,
    required this.quantity,
    required this.category,
    this.isPantry = false,
    this.isShopping = false,
    this.isSuitcase = false,
  });

  // Livello di urgenza "Zero Spreco"
  // Calcolato simbolicamente o basato sulla stringa per la demo
  int get urgencyLevel {
    if (expireDate.contains('Oggi') || expireDate.contains('Domani')) return 2; // Rosso
    if (expireDate.contains('giorni')) return 1; // Giallo
    return 0; // Verde / Fresco
  }
}

class RoommateExpense {
  final String id;
  final String description;
  final double amount;
  final String paidBy;

  RoommateExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
  });
}

class SupermarketModel {
  final String name;
  final String distance;
  final String address;

  SupermarketModel({required this.name, required this.distance, required this.address});
}

class AppState extends ChangeNotifier {
  // ===========================================================================
  // CATEGORIE (Lasciata intatta la divisione in categorie come richiesto)
  // ===========================================================================
  List<String> pantryCategories = [
    "Tutti",
    "Frutta & Verdura",
    "Latticini",
    "Carne & Pesce",
    "Secco & Pasta",
    "Bevande",
  ];

  List<String> shoppingCategories = [
    "Tutti",
    "Frutta & Verdura",
    "Latticini",
    "Carne & Pesce",
    "Secco & Pasta",
    "Igiene Casa",
  ];

  List<String> suitcaseCategories = [
    "Tutti",
    "Vestiti",
    "Libri & Studio",
    "Cavi & Tech",
    "Beauty & Igiene",
  ];

  String selectedPantryCategory = "Tutti";
  String selectedShoppingCategory = "Tutti";
  String selectedSuitcaseCategory = "Tutti";

  // ===========================================================================
  // LISTA PRODOTTI INIZIALI
  // ===========================================================================
  List<ItemModel> allItems = [
    // Prodotti Dispensa
    ItemModel(id: '1', name: 'Latte Parzialmente Scremato', expireDate: 'In scadenza: Oggi', quantity: 1, category: 'Latticini', isPantry: true),
    ItemModel(id: '2', name: 'Insalata Mista Busta', expireDate: 'Scadenza: Domani', quantity: 2, category: 'Frutta & Verdura', isPantry: true),
    ItemModel(id: '3', name: 'Pasta Spaghetti 1kg', expireDate: 'Scadenza: 12/10/2026', quantity: 4, category: 'Secco & Pasta', isPantry: true),
    ItemModel(id: '4', name: 'Passata di Pomodoro', expireDate: 'Scadenza: 25/08/2026', quantity: 3, category: 'Secco & Pasta', isPantry: true),
    ItemModel(id: '5', name: 'Petti di Pollo', expireDate: 'Scadenza: tra 3 giorni', quantity: 1, category: 'Carne & Pesce', isPantry: true),
    
    // Prodotti Lista della Spesa (Predictive / Mancanti)
    ItemModel(id: '6', name: 'Olio Extravergine', expireDate: '-', quantity: 1, category: 'Secco & Pasta', isShopping: true),
    ItemModel(id: '7', name: 'Detersivo Piatti', expireDate: '-', quantity: 2, category: 'Igiene Casa', isShopping: true),
    ItemModel(id: '8', name: 'Mele Golden', expireDate: '-', quantity: 6, category: 'Frutta & Verdura', isShopping: true),

    // Prodotti Valigia
    ItemModel(id: '9', name: 'Magliette di ricambio', expireDate: '-', quantity: 5, category: 'Vestiti', isSuitcase: true),
    ItemModel(id: '10', name: 'Caricabatterie PC e Telefono', expireDate: '-', quantity: 2, category: 'Cavi & Tech', isSuitcase: true),
    ItemModel(id: '11', name: 'Appunti ed Esami passati', expireDate: '-', quantity: 3, category: 'Libri & Studio', isSuitcase: true),
  ];

  // ===========================================================================
  // SPESE CONDIVISE COINQUILINI (House Sync)
  // ===========================================================================
  List<RoommateExpense> expenses = [
    RoommateExpense(id: 'e1', description: 'Spesa settimanale Esselunga', amount: 64.50, paidBy: 'Tu'),
    RoommateExpense(id: 'e2', description: 'Detersivi e Spugne', amount: 12.80, paidBy: 'Marco (Coinquilino)'),
    RoommateExpense(id: 'e3', description: 'Ricarica Acqua e Bevande', amount: 15.00, paidBy: 'Giulia (Coinquilina)'),
  ];

  // ===========================================================================
  // SUPERMERCATI NELLE VICINANZE (Ottimizzazione dei tempi)
  // ===========================================================================
  List<SupermarketModel> nearbySupermarkets = [
    SupermarketModel(name: 'Conad City (Convenzionato Studenti)', distance: '120m', address: 'Via dell\'Università, 14'),
    SupermarketModel(name: 'Esselunga Superstore', distance: '450m', address: 'Viale dello Sport, 88'),
    SupermarketModel(name: 'Lidl (Offerte Fuorisede)', distance: '600m', address: 'Via Roma, 212'),
  ];

  // ===========================================================================
  // LOGICA E AZIONI
  // ===========================================================================
  
  // Cambia categoria attiva
  void selectCategory(String category, String section) {
    if (section == 'pantry') selectedPantryCategory = category;
    if (section == 'shopping') selectedShoppingCategory = category;
    if (section == 'suitcase') selectedSuitcaseCategory = category;
    notifyListeners();
  }

  // Aggiunta dinamica di una nuova categoria dal menu verticale (+)
  void addCustomCategory(String newCategory, String section) {
    if (newCategory.trim().isEmpty) return;
    if (section == 'pantry' && !pantryCategories.contains(newCategory)) {
      pantryCategories.add(newCategory);
      selectedPantryCategory = newCategory;
    } else if (section == 'shopping' && !shoppingCategories.contains(newCategory)) {
      shoppingCategories.add(newCategory);
      selectedShoppingCategory = newCategory;
    } else if (section == 'suitcase' && !suitcaseCategories.contains(newCategory)) {
      suitcaseCategories.add(newCategory);
      selectedSuitcaseCategory = newCategory;
    }
    notifyListeners();
  }

  // Modifica quantità (+ / -) come da layout nativo
  void updateQuantity(String itemId, int delta) {
    final item = allItems.firstWhere((i) => i.id == itemId);
    item.quantity += delta;
    if (item.quantity < 0) item.quantity = 0;
    notifyListeners();
  }

  // Aggiungi un nuovo elemento manualmente
  void addItem(ItemModel newItem) {
    allItems.add(newItem);
    notifyListeners();
  }

  // Spostamento di un prodotto da Lista della Spesa a Dispensa (Spesa Fatta)
  void markShoppingDone() {
    for (var item in allItems.where((i) => i.isShopping).toList()) {
      // Aggiorna lo stato: diventa un prodotto in dispensa
      item.isShopping = false;
      item.isPantry = true;
      item.expireDate = "Scadenza: Fresco (30 gg)";
    }
    notifyListeners();
  }

  // Aggiungi una spesa condivisa
  void addExpense(String description, double amount, String paidBy) {
    expenses.add(RoommateExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      paidBy: paidBy,
    ));
    notifyListeners();
  }

  // Calcolo riassunto bilancio coinquilini
  double get totalExpenses {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  double get myPaidExpenses {
    return expenses.where((e) => e.paidBy == 'Tu').fold(0, (sum, e) => sum + e.amount);
  }
}
