import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'user_model.dart';

class ItemModel {
  final String id;
  String name;
  String expireDate; // Formato testuale "gg/mm/aaaa" come da layout nativo
  int quantity;
  String category;
  bool isPantry;
  bool isShopping;

  ItemModel({
    required this.id,
    required this.name,
    required this.expireDate,
    required this.quantity,
    required this.category,
    this.isPantry = false,
    this.isShopping = false,
  });

  DateTime? get parsedExpireDate {
    String cleanText = expireDate.replaceAll("In scadenza: ", "").replaceAll("Scadenza: ", "").trim();
    if (cleanText == "-" || cleanText.isEmpty) return null;
    final dateParts = cleanText.split('/');
    if (dateParts.length == 3) {
      final day = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  // Livello di urgenza "Zero Spreco"
  int get urgencyLevel {
    String cleanText = expireDate.replaceAll("In scadenza: ", "").replaceAll("Scadenza: ", "").trim();
    if (cleanText == "-" || cleanText.isEmpty) return 0;

    // Se è nel formato gg/mm/aaaa
    final dateParts = cleanText.split('/');
    if (dateParts.length == 3) {
      final day = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);
      if (day != null && month != null && year != null) {
        final expDate = DateTime(year, month, day);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final difference = expDate.difference(today).inDays;
        
        if (difference <= 1) return 2; // Oggi, Domani, o già scaduto (Rosso)
        if (difference <= 7) return 1; // Tra 2 e 7 giorni (Giallo)
        return 0; // Verde / Fresco
      }
    }

    if (cleanText.toLowerCase().contains('oggi') || cleanText.toLowerCase().contains('domani')) return 2; // Rosso
    if (cleanText.toLowerCase().contains('giorni')) {
      final match = RegExp(r'tra (\d+) giorn[io]').firstMatch(cleanText);
      if (match != null) {
        final days = int.parse(match.group(1)!);
        if (days <= 1) return 2;
        if (days <= 7) return 1;
      }
      return 1; // Giallo
    }
    return 0; // Verde / Fresco
  }
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
  final AuthService authService = AuthService();
  UserModel? currentUserData;
  User? currentUserAuth;

  String? groupId;
  List<String> savedGroups = []; // Cronologia locale dei codici gruppo visitati

  bool _isPredictiveBannerClosed = false;
  bool get isPredictiveBannerClosed => _isPredictiveBannerClosed;

  bool _categoryDeleteHintShown = false;
  bool get categoryDeleteHintShown => _categoryDeleteHintShown;

  Future<void> _checkCategoryDeleteHint() async {
    final userId = currentUserAuth?.uid;
    final group = groupId;
    if (userId == null || group == null) {
      _categoryDeleteHintShown = false;
      notifyListeners();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _categoryDeleteHintShown = prefs.getBool('category_delete_hint_shown_${userId}_$group') ?? false;
      notifyListeners();
    } catch (e) {
      print("Errore caricamento stato hint categoria: $e");
    }
  }

  Future<void> markCategoryDeleteHintShown() async {
    final userId = currentUserAuth?.uid;
    final group = groupId;
    if (userId == null || group == null) return;

    _categoryDeleteHintShown = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('category_delete_hint_shown_${userId}_$group', true);
    } catch (e) {
      print("Errore salvataggio stato hint categoria: $e");
    }
  }

  Future<void> _checkPredictiveBannerStatus() async {
    final userId = currentUserAuth?.uid;
    final group = groupId;
    if (userId == null || group == null) {
      _isPredictiveBannerClosed = false;
      notifyListeners();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPredictiveBannerClosed = prefs.getBool('predictive_banner_closed_${userId}_$group') ?? false;
      notifyListeners();
    } catch (e) {
      print("Errore caricamento stato banner: $e");
    }
  }

  Future<void> closePredictiveBannerPermanent() async {
    final userId = currentUserAuth?.uid;
    final group = groupId;
    if (userId == null || group == null) return;
    
    _isPredictiveBannerClosed = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('predictive_banner_closed_${userId}_$group', true);
    } catch (e) {
      print("Errore salvataggio stato banner chiuso: $e");
    }
  }

  AppState() {
    _checkCategoryDeleteHint();
    authService.authStateChanges.listen((User? user) async {
      currentUserAuth = user;
      if (user != null) {
        currentUserData = await authService.getUserData(user.uid);
        if (currentUserData == null) {
          // Risoluzione Race Condition: durante la registrazione Auth triggera prima che la scrittura su Firestore sia completata
          await Future.delayed(const Duration(milliseconds: 800));
          currentUserData = await authService.getUserData(user.uid);
        }

        // AUTO-LOGIN AL GRUPPO
        if (currentUserData != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            final lastActive = prefs.getString('lastActiveGroupId');
            if (lastActive != null && currentUserData!.groupIds.contains(lastActive)) {
              setGroupId(lastActive); // Background
            }
          } catch (_) {}
        }
      } else {
        currentUserData = null;
        await leaveGroup();
      }
      await _checkPredictiveBannerStatus();
      await _checkCategoryDeleteHint();
      notifyListeners();
    });
  }

  FirebaseService? _firebaseService;
  StreamSubscription<List<ItemModel>>? _itemsSubscription;
  StreamSubscription<DocumentSnapshot>? _groupSubscription;

  bool isLoading = false;
  bool groupWasDeleted = false; // Aggiunto per il flag di eliminazione gruppo

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
    groupWasDeleted = false;
    notifyListeners();

    await _checkPredictiveBannerStatus();
    await _checkCategoryDeleteHint();

    // Aggiunge alla cronologia (o sposta in cima se già presente) e salva localmente
    try {
      final prefs = await SharedPreferences.getInstance();
      savedGroups.remove(code);
      savedGroups.insert(0, code);
      await prefs.setStringList('savedGroups', savedGroups);
      await prefs.setString('lastActiveGroupId', code);
    } catch (e) {
      print("Errore salvataggio SharedPreferences: $e");
    }

    _firebaseService = FirebaseService(groupId: groupId!);

    // Esegue il seeding in background senza bloccare la navigazione utente
    _firebaseService!.seedInitialDataIfNeeded(_initialDemoItems, uid: currentUserAuth?.uid);

    // Cancella eventuali sottoscrizioni precedenti
    await _itemsSubscription?.cancel();
    await _groupSubscription?.cancel();

    // Sottoscrizione allo stream degli articoli
    _itemsSubscription = _firebaseService!.getItemsStream().listen(
      (itemsFromCloud) {
        allItems = itemsFromCloud;
        isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Errore stream articoli: $error");
        isLoading = false;
        notifyListeners();
      },
    );

    _groupSubscription = _firebaseService!.getGroupStream().listen((doc) {
      if (!doc.exists && groupId != null) {
        // Il documento del gruppo è stato eliminato
        leaveGroup(deleted: true);
        return;
      }
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        if (data.containsKey('pantryCategories')) {
          final List<dynamic> loaded = data['pantryCategories'];
          pantryCategories = loaded.map((e) => e.toString()).toList();
        }
        if (data.containsKey('shoppingCategories')) {
          final List<dynamic> loaded = data['shoppingCategories'];
          shoppingCategories = loaded.map((e) => e.toString()).toList();
        }
        notifyListeners();
      }
    });
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

  Future<void> deleteGroup() async {
    await _firebaseService?.deleteGroup();
  }

  Future<void> leaveGroup({bool deleted = false}) async {
    // Se il gruppo è stato eliminato, impostiamo il flag per la UI e rimuoviamo dalle cronologie
    if (deleted) {
      groupWasDeleted = true;
      if (groupId != null) {
        savedGroups.remove(groupId);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('savedGroups', savedGroups);
        } catch (_) {}
        
        if (currentUserData != null) {
          currentUserData!.groupIds.remove(groupId);
        }
      }
    }
    
    // Aspetta che tutte le scritture pendenti su Firestore vengano completate
    try {
      await FirebaseFirestore.instance.waitForPendingWrites().timeout(const Duration(seconds: 3));
    } catch (e) {
      print("Errore o timeout nel salvataggio dei dati pendenti su Firebase: $e");
    }

    groupId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastActiveGroupId');
    } catch (_) {}
    await _itemsSubscription?.cancel();
    _itemsSubscription = null;
    await _groupSubscription?.cancel();
    _groupSubscription = null;
    _isPredictiveBannerClosed = false;

    // Ripristina le liste di default per permettere l'ingresso pulito in un altro gruppo
    allItems.clear();
    allItems.addAll(_initialDemoItems);

    notifyListeners();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _groupSubscription?.cancel();
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

  String selectedPantryCategory = "Tutti";
  String selectedShoppingCategory = "Tutti";

  // ===========================================================================
  // LISTE DI BACKUP / DEMO INIZIALI
  // ===========================================================================
  final List<ItemModel> _initialDemoItems = [];

  // Liste attive (inizializzate con i dati demo per fallback)
  late List<ItemModel> allItems = List.from(_initialDemoItems);

  // ===========================================================================
  // SUPERMERCATI NELLE VICINANZE
  // ===========================================================================
  List<SupermarketModel> nearbySupermarkets = [];

  // ===========================================================================
  // LOGICA E AZIONI SINCRO
  // ===========================================================================
  
  void selectCategory(String category, String section) {
    if (section == 'pantry') selectedPantryCategory = category;
    if (section == 'shopping') selectedShoppingCategory = category;
    notifyListeners();
  }

  void addCustomCategory(String newCategory, String section) {
    if (newCategory.trim().isEmpty) return;
    bool updated = false;
    if (section == 'pantry' && !pantryCategories.contains(newCategory)) {
      pantryCategories.add(newCategory);
      selectedPantryCategory = newCategory;
      updated = true;
    } else if (section == 'shopping' && !shoppingCategories.contains(newCategory)) {
      shoppingCategories.add(newCategory);
      selectedShoppingCategory = newCategory;
      updated = true;
    }
    if (updated) {
      notifyListeners();
      _firebaseService?.updateCategories(pantryCategories, shoppingCategories);
    }
  }

  void removeCustomCategory(String categoryToRemove, String section) {
    if (categoryToRemove == "Tutti") return; // "Tutti" non può mai essere eliminato

    if (section == 'pantry') {
      pantryCategories.remove(categoryToRemove);
      if (selectedPantryCategory == categoryToRemove) {
        selectedPantryCategory = "Tutti";
      }
    } else if (section == 'shopping') {
      shoppingCategories.remove(categoryToRemove);
      if (selectedShoppingCategory == categoryToRemove) {
        selectedShoppingCategory = "Tutti";
      }
    }
    notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int delta) async {
    try {
      final item = allItems.firstWhere((i) => i.id == itemId);
      item.quantity += delta;
      
      if (item.quantity <= 0) {
        allItems.remove(item);
        notifyListeners();
        await _firebaseService?.deleteItem(itemId);
      } else {
        notifyListeners();
        await _firebaseService?.updateItemQuantity(itemId, item.quantity);
      }
    } catch (e) {
      print("Prodotto non trovato localmente: $e");
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      allItems.removeWhere((i) => i.id == itemId);
      notifyListeners();
      await _firebaseService?.deleteItem(itemId);
    } catch (e) {
      print("Errore eliminazione locale: $e");
    }
  }

  Future<void> addItem(ItemModel newItem) async {
    try {
      // Cerca un prodotto identico (nome uguale case-insensitive) nella stessa sezione
      final existingItem = allItems.firstWhere(
        (i) => i.name.trim().toLowerCase() == newItem.name.trim().toLowerCase() &&
               i.isPantry == newItem.isPantry &&
               i.isShopping == newItem.isShopping,
      );
      
      // Se esiste, aggiorna solo la quantità
      await updateQuantity(existingItem.id, newItem.quantity);
    } catch (e) {
      // Nessun duplicato trovato, aggiungi come nuovo elemento
      allItems.add(newItem);
      notifyListeners();
      await _firebaseService?.saveItem(newItem);
    }
  }

  Future<void> updateItem(ItemModel updatedItem) async {
    final index = allItems.indexWhere((i) => i.id == updatedItem.id);
    if (index != -1) {
      allItems[index] = updatedItem;
      notifyListeners();
      await _firebaseService?.saveItem(updatedItem);
    }
  }

  Future<void> moveToShoppingList(ItemModel oldItem) async {
    // Aggiungi alla spesa
    final newItem = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: oldItem.name,
      expireDate: "-",
      quantity: 1,
      category: oldItem.category,
      isPantry: false,
      isShopping: true,
    );
    await addItem(newItem);
    
    // Rimuovi dalla dispensa
    await deleteItem(oldItem.id);
  }

  Future<void> markSelectedShoppingDone(List<String> selectedItemIds) async {
    for (var item in allItems.where((i) => i.isShopping && selectedItemIds.contains(i.id)).toList()) {
      item.isShopping = false;
      item.isPantry = true;
      item.expireDate = "Data: N/A";
      await _firebaseService?.saveItem(item);
    }
    notifyListeners();
  }

  Future<void> markShoppingDone() async {
    for (var item in allItems.where((i) => i.isShopping).toList()) {
      item.isShopping = false;
      item.isPantry = true;
      item.expireDate = "Data: N/A";
      await _firebaseService?.saveItem(item);
    }
    notifyListeners();
  }

  Future<void> updateProfileName(String newName) async {
    try {
      final user = currentUserAuth;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newName,
        });
        currentUserData = UserModel(
          id: user.uid,
          email: user.email ?? "",
          name: newName,
          groupIds: currentUserData?.groupIds ?? [],
        );
        notifyListeners();
      }
    } catch (e) {
      print("Errore aggiornamento nome utente: $e");
    }
  }
}
