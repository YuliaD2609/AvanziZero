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

  AppState() {
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
      notifyListeners();
    });
  }

  FirebaseService? _firebaseService;
  StreamSubscription<List<ItemModel>>? _itemsSubscription;

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
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!savedGroups.contains(code)) {
        savedGroups.insert(0, code);
        await prefs.setStringList('savedGroups', savedGroups);
      }
      await prefs.setString('lastActiveGroupId', code);
    } catch (e) {
      print("Errore salvataggio SharedPreferences: $e");
    }

    _firebaseService = FirebaseService(groupId: groupId!);

    // Esegue il seeding in background senza bloccare la navigazione utente
    _firebaseService!.seedInitialDataIfNeeded(_initialDemoItems, uid: currentUserAuth?.uid);

    // Cancella eventuali sottoscrizioni precedenti
    await _itemsSubscription?.cancel();

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

  Future<void> leaveGroup() async {
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

    // Ripristina le liste di default per permettere l'ingresso pulito in un altro gruppo
    allItems.clear();
    allItems.addAll(_initialDemoItems);

    notifyListeners();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
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
  final List<ItemModel> _initialDemoItems = [];

  // Liste attive (inizializzate con i dati demo per fallback)
  late List<ItemModel> allItems = List.from(_initialDemoItems);

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
               i.isShopping == newItem.isShopping &&
               i.isSuitcase == newItem.isSuitcase,
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

  Future<void> markShoppingDone() async {
    for (var item in allItems.where((i) => i.isShopping).toList()) {
      item.isShopping = false;
      item.isPantry = true;
      item.expireDate = "Scadenza: Fresco (30 gg)";
    }
    notifyListeners();
    await _firebaseService?.markShoppingDone();
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
