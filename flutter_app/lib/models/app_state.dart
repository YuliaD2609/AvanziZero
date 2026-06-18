import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'user_model.dart';

bool globalIsDarkMode = false;

class ItemModel {
  final String id;
  String name;
  String expireDate; // Formato testuale "gg/mm/aaaa" come da layout nativo
  int quantity;
  String category;
  bool isPantry;
  bool isShopping;
  String? ownerId;

  ItemModel({
    required this.id,
    required this.name,
    required this.expireDate,
    required this.quantity,
    required this.category,
    this.isPantry = false,
    this.isShopping = false,
    this.ownerId,
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
  List<UserModel> groupMembers = []; // Utenti del gruppo attivo

  Color getMemberColor(String uid) {
    if (groupId == null) return Colors.grey;
    final List<Color> palette = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
      Colors.brown, Colors.cyan, Colors.amber, Colors.deepOrange
    ];
    int hash = (uid + groupId!).hashCode;
    return palette[hash.abs() % palette.length];
  }

  bool _isPredictiveBannerClosed = false;
  bool get isPredictiveBannerClosed => _isPredictiveBannerClosed;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      globalIsDarkMode = _isDarkMode;
      notifyListeners();
    } catch (e) {
      print("Errore caricamento tema: $e");
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    globalIsDarkMode = _isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      print("Errore salvataggio tema: $e");
    }
  }

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
    _loadThemePreference();
    _checkCategoryDeleteHint();
    authService.authStateChanges.listen((User? user) async {
      isInitializingUser = true;
      notifyListeners();
      
      currentUserAuth = user;
      if (user != null) {
        _userDocSubscription?.cancel();
        _userDocSubscription = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().listen((doc) async {
          if (doc.exists) {
            currentUserData = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            
            // Carica la cronologia specifica dell'utente appena loggato
            await loadSavedGroups();

            // AUTO-LOGIN AL GRUPPO
            try {
              final prefs = await SharedPreferences.getInstance();
              final lastActive = prefs.getString('lastActiveGroupId_${user.uid}');
              if (lastActive != null && currentUserData!.groupIds.contains(lastActive)) {
                if (groupId != lastActive) setGroupId(lastActive); // Background
              }
            } catch (_) {}
            
            isInitializingUser = false;
            notifyListeners();
          }
        });
      } else {
        _userDocSubscription?.cancel();
        currentUserData = null;
        savedGroups.clear();
        savedGroupNames.clear();
        isInitializingUser = false;
        await leaveGroup();
      }
      await _checkPredictiveBannerStatus();
      await _checkCategoryDeleteHint();
      notifyListeners();
    });
  }

  FirebaseService? _firebaseService;
  FirebaseService? get firebaseService => _firebaseService;
  StreamSubscription<List<ItemModel>>? _itemsSubscription;
  StreamSubscription<DocumentSnapshot>? _groupSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  bool isInitializingUser = true; // Mostra loader all'avvio finché non carichiamo i dati utente
  bool isLoading = false;
  bool groupWasDeleted = false; // Aggiunto per il flag di eliminazione gruppo
  bool userWasKicked = false; // Aggiunto per il flag di rimozione dal gruppo
  String? groupName;
  Map<String, String> savedGroupNames = {}; // Codice Gruppo -> Nome Gruppo

  /// Carica la cronologia dei gruppi visitati dalla memoria persistente
  Future<void> loadSavedGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'savedGroups_${currentUserAuth?.uid ?? ''}';
      savedGroups = prefs.getStringList(key) ?? [];
      final groupNamesJson = prefs.getString('savedGroupNames');
      if (groupNamesJson != null) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(groupNamesJson);
          savedGroupNames = decoded.map((key, value) => MapEntry(key, value.toString()));
        } catch (_) {}
      }
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
    userWasKicked = false;
    notifyListeners();

    await _checkPredictiveBannerStatus();
    await _checkCategoryDeleteHint();

    // Aggiunge alla cronologia (o sposta in cima se già presente) e salva localmente
    try {
      final prefs = await SharedPreferences.getInstance();
      savedGroups.remove(code);
      savedGroups.insert(0, code);
      final key = 'savedGroups_${currentUserAuth?.uid ?? ''}';
      await prefs.setStringList(key, savedGroups);
      await prefs.setString('lastActiveGroupId_${currentUserAuth?.uid ?? ''}', code);
    } catch (e) {
      print("Errore salvataggio SharedPreferences: $e");
    }

    _firebaseService = FirebaseService(groupId: groupId!);

    // Esegue il seeding aspettando il completamento per evitare race condition con lo stream
    // (altrimenti lo stream leggerebbe "non esiste" e scatenerebbe leaveGroup)
    await _firebaseService!.seedInitialDataIfNeeded(_initialDemoItems, uid: currentUserAuth?.uid);

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

    bool groupDidExist = false;
    _groupSubscription = _firebaseService!.getGroupStream().listen((doc) {
      if (doc.exists) {
        groupDidExist = true;
        final data = doc.data() as Map<String, dynamic>? ?? {};
        
        groupName = data['name'];
        if (groupName != null && groupName!.isNotEmpty && groupId != null) {
          savedGroupNames[groupId!] = groupName!;
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('savedGroupNames', jsonEncode(savedGroupNames));
          });
        }

        if (data.containsKey('categories')) {
          final List<dynamic> loaded = data['categories'];
          categories = loaded.map((e) => e.toString()).toList();
        } else {
          // Migrazione dalle vecchie liste separate
          Set<String> merged = {"Tutti", "Altro", "Frutta & Verdura", "Latticini", "Carne", "Bevande", "Snack"};
          if (data.containsKey('pantryCategories')) {
            merged.addAll((data['pantryCategories'] as List).map((e) => e.toString()));
          }
          if (data.containsKey('shoppingCategories')) {
            merged.addAll((data['shoppingCategories'] as List).map((e) => e.toString()));
          }
          categories = merged.toList();
          
          // Salva la lista unificata su Firebase per sincronizzarla con tutti
          if (groupDidExist && _firebaseService != null) {
            _firebaseService!.updateCategories(categories);
          }
        }
        if (data.containsKey('members')) {
          final List<dynamic> loadedMembers = data['members'];
          final memberStrings = loadedMembers.map((e) => e.toString()).toList();
          
          if (currentUserAuth != null && !memberStrings.contains(currentUserAuth!.uid)) {
            leaveGroup(kicked: true);
            return;
          }
          
          _fetchGroupMembers(memberStrings);
        }
        notifyListeners();
      } else if (!doc.exists && groupId != null && groupDidExist) {
        // Il documento del gruppo è stato eliminato solo se l'abbiamo già visto esistere
        leaveGroup(deleted: true);
      }
    });

  }

  Future<void> _fetchGroupMembers(List<String> uids) async {
    List<UserModel> members = [];
    for (String uid in uids) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          members.add(UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        }
      } catch (e) {
        print("Errore caricamento membro $uid: $e");
      }
    }
    groupMembers = members;
    notifyListeners();
  }

  /// Rimuove un gruppo specifico dalla cronologia locale
  Future<void> removeSavedGroup(String code) async {
    savedGroups.remove(code);
    savedGroupNames.remove(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'savedGroups_${currentUserAuth?.uid ?? ''}';
      await prefs.setStringList(key, savedGroups);
      await prefs.setString('savedGroupNames', jsonEncode(savedGroupNames));
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

  Future<void> updateGroupName(String newName) async {
    if (groupId != null) {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'name': newName.trim(),
      });
    }
  }

  Future<void> leaveGroup({bool deleted = false, bool kicked = false}) async {
    // Se il gruppo è stato eliminato o l'utente rimosso, impostiamo il flag per la UI
    if (deleted) groupWasDeleted = true;
    if (kicked) userWasKicked = true;

    if (deleted || kicked) {
      if (groupId != null) {
        savedGroups.remove(groupId);
        savedGroupNames.remove(groupId);
        try {
          final prefs = await SharedPreferences.getInstance();
          final key = 'savedGroups_${currentUserAuth?.uid ?? ''}';
          await prefs.setStringList(key, savedGroups);
          await prefs.setString('savedGroupNames', jsonEncode(savedGroupNames));
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
    groupName = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastActiveGroupId_${currentUserAuth?.uid ?? ''}');
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
    _userDocSubscription?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // STATO UI E FILTRI (Locale)
  // ===========================================================================
  List<String> categories = [
    "Tutti",
    "Altro",
    "Frutta & Verdura",
    "Latticini",
    "Carne",
    "Bevande",
    "Snack"
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
    
    if (!categories.contains(newCategory)) {
      categories.add(newCategory);
      updated = true;
    }

    if (section == 'pantry') selectedPantryCategory = newCategory;
    if (section == 'shopping') selectedShoppingCategory = newCategory;

    if (updated) {
      notifyListeners();
      _firebaseService?.updateCategories(categories);
    }
  }

  void removeCustomCategory(String categoryToRemove, String section) {
    if (categoryToRemove == "Tutti") return; // "Tutti" non può mai essere eliminato

    bool removed = categories.remove(categoryToRemove);

    if (selectedPantryCategory == categoryToRemove) {
      selectedPantryCategory = "Tutti";
    }
    if (selectedShoppingCategory == categoryToRemove) {
      selectedShoppingCategory = "Tutti";
    }

    if (removed) {
      // Se era un'appartenenza a liste, rimuoviamo le category da quegli item o li spostiamo su 'Altro'
      for (var item in allItems) {
        if (item.category == categoryToRemove) {
          item.category = 'Altro';
          _firebaseService?.saveItem(item);
        }
      }
      notifyListeners();
      _firebaseService?.updateCategories(categories);
    }
  }

  Future<void> updateQuantity(String itemId, int delta) async {
    try {
      final item = allItems.firstWhere((i) => i.id == itemId);
      item.quantity += delta;
      
      if (delta < 0 && item.isPantry) {
        _firebaseService?.logConsumption(item.name, -delta);
      }
      
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
      final item = allItems.firstWhere((i) => i.id == itemId);
      if (item.isPantry) {
        _firebaseService?.logConsumption(item.name, item.quantity);
      }
      
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
