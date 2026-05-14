import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

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
  // GESTIONE CLOUD & SINCRO REAL-TIME (FIREBASE)
  // ===========================================================================
  String? groupId;
  List<String> savedGroups = []; // Cronologia locale dei codici gruppo visitati
  FirebaseService? _firebaseService;
  StreamSubscription<List<ItemModel>>? _itemsSubscription;
  StreamSubscription<List<RoommateExpense>>? _expensesSubscription;

  bool isLoading = false;

  /// Carica la cronologia dei gruppi visitati dalla memoria persistente
  Future<void> loadSavedGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      savedGroups = prefs.getStringList('savedGroups') ?? [];
      notifyListeners();
    } catch (e) {
      print("Errore nel caricamento della cronologia gruppi: $e");
    }
  }

  /// Imposta il codice del gruppo (Casa), avvia la sincronizzazione e lo salva nella cronologia.
  Future<void> setGroupId(String newGroupId) async {
    if (newGroupId.trim().isEmpty) return;
    
    final code = newGroupId.trim().toUpperCase();
    groupId = code;
    isLoading = true;
    notifyListeners();

    // Aggiunge alla cronologia se non presente e salva localmente
    if (!savedGroups.contains(code)) {
      savedGroups.insert(0, code);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('savedGroups', savedGroups);
      } catch (e) {
        print("Errore salvataggio cronologia: $e");
      }
    }

    _firebaseService = FirebaseService(groupId: groupId!);

    // Copia i dati demo iniziali su Firestore se il gruppo è appena stato creato
    await _firebaseService!.seedInitialDataIfNeeded(_initialDemoItems, _initialDemoExpenses);

    // Cancella eventuali sottoscrizioni precedenti
    await _itemsSubscription?.cancel();
    await _expensesSubscription?.cancel();

    // Sottoscrizione allo stream degli articoli
    _itemsSubscription = _firebaseService!.getItemsStream().listen(
      (itemsFromCloud) {
        if (itemsFromCloud.isNotEmpty) {
          allItems = itemsFromCloud;
        }
        isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Errore stream articoli: $error");
        isLoading = false;
        notifyListeners();
      },
    );

    // Sottoscrizione allo stream delle spese condivise
    _expensesSubscription = _firebaseService!.getExpensesStream().listen(
      (expensesFromCloud) {
        if (expensesFromCloud.isNotEmpty) {
          expenses = expensesFromCloud;
        }
        notifyListeners();
      },
      onError: (error) => print("Errore stream spese: $error"),
    );
  }

  /// Rimuove un gruppo specifico dalla cronologia locale
  Future<void> removeSavedGroup(String code) async {
    savedGroups.remove(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('savedGroups', savedGroups);
    } catch (e) {
      print("Errore rimozione gruppo da SharedPreferences: $e");
    }
    
    // Se elimino il gruppo in cui mi trovo attualmente, esco dal gruppo
    if (groupId == code) {
      await leaveGroup();
    } else {
      notifyListeners();
    }
  }

  /// Esce dal gruppo corrente, scollega gli stream e ripristina la UI in modalità base.
  Future<void> leaveGroup() async {
    groupId = null;
    await _itemsSubscription?.cancel();
    await _expensesSubscription?.cancel();
    _itemsSubscription = null;
    _expensesSubscription = null;
    _firebaseService = null;

    // Ripristina le liste di default per permettere l'ingresso pulito in un altro gruppo
    allItems = List.from(_initialDemoItems);
    expenses = List.from(_initialDemoExpenses);

    notifyListeners();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _expensesSubscription?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // CATEGORIE
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
  // LISTE DI BACKUP / DEMO INIZIALI
  // ===========================================================================
  final List<ItemModel> _initialDemoItems = [
    ItemModel(id: '1', name: 'Latte Parzialmente Scremato', expireDate: 'In scadenza: Oggi', quantity: 1, category: 'Latticini', isPantry: true),
    ItemModel(id: '2', name: 'Insalata Mista Busta', expireDate: 'Scadenza: Domani', quantity: 2, category: 'Frutta & Verdura', isPantry: true),
    ItemModel(id: '3', name: 'Pasta Spaghetti 1kg', expireDate: 'Scadenza: 12/10/2026', quantity: 4, category: 'Secco & Pasta', isPantry: true),
    ItemModel(id: '4', name: 'Passata di Pomodoro', expireDate: 'Scadenza: 25/08/2026', quantity: 3, category: 'Secco & Pasta', isPantry: true),
    ItemModel(id: '5', name: 'Petti di Pollo', expireDate: 'Scadenza: tra 3 giorni', quantity: 1, category: 'Carne & Pesce', isPantry: true),
    ItemModel(id: '6', name: 'Olio Extravergine', expireDate: '-', quantity: 1, category: 'Secco & Pasta', isShopping: true),
    ItemModel(id: '7', name: 'Detersivo Piatti', expireDate: '-', quantity: 2, category: 'Igiene Casa', isShopping: true),
    ItemModel(id: '8', name: 'Mele Golden', expireDate: '-', quantity: 6, category: 'Frutta & Verdura', isShopping: true),
    ItemModel(id: '9', name: 'Magliette di ricambio', expireDate: '-', quantity: 5, category: 'Vestiti', isSuitcase: true),
    ItemModel(id: '10', name: 'Caricabatterie PC e Telefono', expireDate: '-', quantity: 2, category: 'Cavi & Tech', isSuitcase: true),
    ItemModel(id: '11', name: 'Appunti ed Esami passati', expireDate: '-', quantity: 3, category: 'Libri & Studio', isSuitcase: true),
  ];

  final List<RoommateExpense> _initialDemoExpenses = [
    RoommateExpense(id: 'e1', description: 'Spesa settimanale Esselunga', amount: 64.50, paidBy: 'Tu'),
    RoommateExpense(id: 'e2', description: 'Detersivi e Spugne', amount: 12.80, paidBy: 'Marco (Coinquilino)'),
    RoommateExpense(id: 'e3', description: 'Ricarica Acqua e Bevande', amount: 15.00, paidBy: 'Giulia (Coinquilina)'),
  ];

  // Liste attive (inizializzate con i dati demo per fallback)
  late List<ItemModel> allItems = List.from(_initialDemoItems);
  late List<RoommateExpense> expenses = List.from(_initialDemoExpenses);

  // ===========================================================================
  // SUPERMERCATI NELLE VICINANZE
  // ===========================================================================
  List<SupermarketModel> nearbySupermarkets = [
    SupermarketModel(name: 'Conad City (Convenzionato Studenti)', distance: '120m', address: 'Via dell\'Università, 14'),
    SupermarketModel(name: 'Esselunga Superstore', distance: '450m', address: 'Viale dello Sport, 88'),
    SupermarketModel(name: 'Lidl (Offerte Fuorisede)', distance: '600m', address: 'Via Roma, 212'),
  ];

  // ===========================================================================
  // LOGICA E AZIONI SINCRO
  // ===========================================================================
  
  void selectCategory(String category, String section) {
    if (section == 'pantry') selectedPantryCategory = category;
    if (section == 'shopping') selectedShoppingCategory = category;
    if (section == 'suitcase') selectedSuitcaseCategory = category;
    notifyListeners();
  }

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

  void updateQuantity(String itemId, int delta) {
    try {
      final item = allItems.firstWhere((i) => i.id == itemId);
      item.quantity += delta;
      if (item.quantity < 0) item.quantity = 0;

      _firebaseService?.updateItemQuantity(itemId, item.quantity);
      notifyListeners();
    } catch (e) {
      print("Prodotto non trovato localmente: $e");
    }
  }

  void addItem(ItemModel newItem) {
    allItems.add(newItem);
    _firebaseService?.saveItem(newItem);
    notifyListeners();
  }

  void markShoppingDone() {
    for (var item in allItems.where((i) => i.isShopping).toList()) {
      item.isShopping = false;
      item.isPantry = true;
      item.expireDate = "Scadenza: Fresco (30 gg)";
    }
    _firebaseService?.markShoppingDone();
    notifyListeners();
  }

  void addExpense(String description, double amount, String paidBy) {
    final newExp = RoommateExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      paidBy: paidBy,
    );
    expenses.add(newExp);
    _firebaseService?.addExpense(newExp);
    notifyListeners();
  }

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);

  double get myPaidExpenses => expenses.where((e) => e.paidBy == 'Tu').fold(0, (sum, e) => sum + e.amount);
}
