import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../main.dart';
import 'user_model.dart';

bool globalIsDarkMode = false;

class ItemModel {
  final String id;
  String name;
  String expireDate; // Formato testuale "gg/mm/aaaa" come da layout nativo
  List<String> expireDates; // Lista di tutte le date di scadenza per le istanze multiple
  int quantity;
  String category;
  bool isPantry;
  bool isShopping;
  String? ownerId;

  ItemModel({
    required this.id,
    required this.name,
    this.expireDate = "-",
    List<String>? expireDates,
    this.quantity = 1,
    required this.category,
    this.isPantry = false,
    this.isShopping = false,
    this.ownerId,
  }) : expireDates = expireDates ?? (expireDate != "-" && expireDate != "Data: N/A" && expireDate.isNotEmpty ? [expireDate] : []);

  String get _cleanDateText => expireDate
      .replaceAll("In scadenza: ", "")
      .replaceAll("Scadenza: ", "")
      .trim();

  DateTime? get parsedExpireDate {
    final cleanText = _cleanDateText;
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
    
    final match = RegExp(r'tra (\d+) giorn[io]').firstMatch(cleanText);
    if (match != null) {
      final days = int.parse(match.group(1)!);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(Duration(days: days));
    }
    
    if (cleanText.toLowerCase().contains('oggi')) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    if (cleanText.toLowerCase().contains('domani')) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }

    return null;
  }

  bool get isExpired {
    final expDate = parsedExpireDate;
    if (expDate == null) return false;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return expDate.isBefore(todayStart);
  }

  int get urgencyLevel {
    final cleanText = _cleanDateText;
    if (cleanText == "-" || cleanText.isEmpty) return 0;

    final expDate = parsedExpireDate;
    if (expDate != null) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final difference = expDate.difference(todayStart).inDays;

      if (difference <= 1) return 2;
      if (difference <= 7) return 1;
      return 0;
    }

    return 0;
  }

  String get formattedDateForUI {
    final cleanText = _cleanDateText;
    if (cleanText == "-" || cleanText.isEmpty) return "-";

    final expDate = parsedExpireDate;
    if (expDate != null) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final difference = expDate.difference(todayStart).inDays;

      if (difference == 0) return 'Oggi';
      if (difference == 1) return 'Domani';
      if (difference < 0) return cleanText;

      return "${expDate.day.toString().padLeft(2, '0')}/${expDate.month.toString().padLeft(2, '0')}/${expDate.year}";
    }
    return cleanText;
  }
}

class SupermarketModel {
  final String name;
  final String distance;
  final String address;

  SupermarketModel(
      {required this.name, required this.distance, required this.address});
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

  // FR6.6 - Tracking dei feedback IA
  Map<String, Map<String, int>> aiFeedback = {};


  // Proprietà calcolata per i prodotti in scadenza
  List<ItemModel> get expiringItems {
    final items = allItems.where((i) => i.isPantry && i.urgencyLevel > 0).toList();
    items.sort((a, b) {
      if (a.parsedExpireDate == null && b.parsedExpireDate == null) return 0;
      if (a.parsedExpireDate == null) return 1;
      if (b.parsedExpireDate == null) return -1;
      return a.parsedExpireDate!.compareTo(b.parsedExpireDate!);
    });
    return items;
  }

  Color getMemberColor(String uid) {
    if (groupId == null) return Colors.grey;
    final List<Color> palette = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
      Colors.amber,
      Colors.deepOrange
    ];
    int hash = (uid + groupId!).hashCode;
    return palette[hash.abs() % palette.length];
  }

  bool _isPredictiveBannerClosed = false;
  bool get isPredictiveBannerClosed => _isPredictiveBannerClosed;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isSidebarVisible = true;
  bool get isSidebarVisible => _isSidebarVisible;

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isSidebarVisible = prefs.getBool('isSidebarVisible') ?? true;
      globalIsDarkMode = _isDarkMode;
      notifyListeners();
    } catch (e) {
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
          }
  }

  Future<void> toggleSidebar() async {
    _isSidebarVisible = !_isSidebarVisible;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSidebarVisible', _isSidebarVisible);
    } catch (e) {
    }
  }

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get notificationTime => _notificationTime;

  Future<void> loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      int hour = prefs.getInt('notificationHour') ?? 9;
      int minute = prefs.getInt('notificationMinute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
      _scheduleNotifications();
      notifyListeners();
    } catch (e) {
          }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', enabled);
      _scheduleNotifications();
    } catch (e) {
          }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notificationHour', time.hour);
      await prefs.setInt('notificationMinute', time.minute);
      _scheduleNotifications();
    } catch (e) {
          }
  }

  void _scheduleNotifications() {
    if (_notificationsEnabled) {
      NotificationService()
          .scheduleDailyPantryCheck(_notificationTime, allItems);
    } else {
      NotificationService().cancelNotifications();
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
      _categoryDeleteHintShown =
          prefs.getBool('category_delete_hint_shown_${userId}_$group') ?? false;
      notifyListeners();
    } catch (e) {
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
      _isPredictiveBannerClosed =
          prefs.getBool('predictive_banner_closed_${userId}_$group') ?? false;
      notifyListeners();
    } catch (e) {
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
        _userDocSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) async {
          if (doc.exists) {
            currentUserData =
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

            // Carica la cronologia specifica dell'utente appena loggato
            await loadSavedGroups();

            // AUTO-LOGIN AL GRUPPO
            try {
              final prefs = await SharedPreferences.getInstance();
              final lastActive =
                  prefs.getString('lastActiveGroupId_${user.uid}');
              if (lastActive != null &&
                  currentUserData!.groupIds.contains(lastActive)) {
                if (groupId != lastActive) setGroupId(lastActive); // Background
              }
            } catch (e) {
                          }

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

  bool isInitializingUser =
      true; // Mostra loader all'avvio finché non carichiamo i dati utente
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
          savedGroupNames =
              decoded.map((key, value) => MapEntry(key, value.toString()));
        } catch (e) {
                  }
      }
      notifyListeners();
    } catch (e) {
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
      await prefs.setString(
          'lastActiveGroupId_${currentUserAuth?.uid ?? ''}', code);
    } catch (e) {
          }

    _firebaseService = FirebaseService(groupId: groupId!);

    // Esegue il seeding aspettando il completamento per evitare race condition con lo stream
    // (altrimenti lo stream leggerebbe "non esiste" e scatenerebbe leaveGroup)
    await _firebaseService!
        .seedInitialDataIfNeeded(_initialDemoItems, uid: currentUserAuth?.uid);

    // Cancella eventuali sottoscrizioni precedenti
    await _itemsSubscription?.cancel();
    await _groupSubscription?.cancel();

    // Sottoscrizione allo stream degli articoli
    _itemsSubscription = _firebaseService!.getItemsStream().listen(
      (itemsFromCloud) {
        allItems = itemsFromCloud;
        isLoading = false;
        notifyListeners();
        _scheduleNotifications();
      },
      onError: (error) {
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

        if (data.containsKey('aiFeedback')) {
          final Map<String, dynamic> rawFeedback = data['aiFeedback'];
          aiFeedback = rawFeedback.map((key, value) {
            return MapEntry(
              key, 
              (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int))
            );
          });
        }

        if (data.containsKey('categories')) {
          final List<dynamic> loaded = data['categories'];
          categories = loaded.map((e) => e.toString()).toList();
        } else {
          // Migrazione dalle vecchie liste separate
          Set<String> merged = {
            "Tutti",
            "Altro",
            "Frutta & Verdura",
            "Latticini",
            "Carne",
            "Bevande",
            "Snack"
          };
          if (data.containsKey('pantryCategories')) {
            merged.addAll(
                (data['pantryCategories'] as List).map((e) => e.toString()));
          }
          if (data.containsKey('shoppingCategories')) {
            merged.addAll(
                (data['shoppingCategories'] as List).map((e) => e.toString()));
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

          if (currentUserAuth != null &&
              !memberStrings.contains(currentUserAuth!.uid)) {
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
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          members.add(
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        }
      } catch (e) {
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
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
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
        } catch (e) {
                  }

        if (currentUserData != null) {
          currentUserData!.groupIds.remove(groupId);
        }
      }
    }

    // Aspetta che tutte le scritture pendenti su Firestore vengano completate
    try {
      await FirebaseFirestore.instance
          .waitForPendingWrites()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
          }

    groupId = null;
    groupName = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastActiveGroupId_${currentUserAuth?.uid ?? ''}');
    } catch (e) {
          }
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
    if (categoryToRemove == "Tutti")
      return; // "Tutti" non può mai essere eliminato

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

  Future<void> _checkAndAutoAddShopping(ItemModel item) async {
    final history = await _firebaseService?.getConsumptionHistory() ?? [];
    int consumedCount = 0;
    String targetName = item.name.toLowerCase().trim();

    for (var log in history) {
      if ((log['name'] ?? '').toString().toLowerCase().trim() == targetName) {
        consumedCount += (log['quantity'] ?? 1) as int;
      }
    }

    if (consumedCount >= 3) {
      bool alreadyInShopping = allItems.any(
          (i) => i.isShopping && i.name.toLowerCase().trim() == targetName);
      if (!alreadyInShopping) {
        ItemModel newItem = ItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: item.name,
          expireDate: "-",
          quantity: 1,
          category: item.category,
          isShopping: true,
        );
        newItem.isPantry = false;
        allItems.add(newItem);
        notifyListeners();
        await _firebaseService?.saveItem(newItem);

        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
                "IA: ${item.name} sta finendo ed è stato aggiunto alla Spesa automatica!"),
            backgroundColor: const Color(0xFF4A7C59),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> updateQuantity(String itemId, int delta) async {
    try {
      final item = allItems.firstWhere((i) => i.id == itemId);
      item.quantity += delta;

      if (delta < 0 && item.isPantry) {
        _firebaseService?.logConsumption(item.name, -delta);
        if (item.expireDates.length > item.quantity) {
          item.expireDates.removeAt(0);
          item.expireDate = item.expireDates.isNotEmpty ? item.expireDates.first : "-";
        }
      }

      if (item.quantity <= 0) {
        allItems.remove(item);
        notifyListeners();
        await _firebaseService?.deleteItem(itemId);
        if (item.isPantry) _checkAndAutoAddShopping(item);
      } else {
        notifyListeners();
        await _firebaseService?.saveItem(item);
        if (item.quantity == 1 && item.isPantry && delta < 0) {
          _checkAndAutoAddShopping(item);
        }
      }
    } catch (e) {
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
          }
  }

  Future<void> addItem(ItemModel newItem) async {
    try {
      // Cerca un prodotto identico (nome uguale case-insensitive) nella stessa sezione
      final existingItem = allItems.firstWhere(
        (i) =>
            i.name.trim().toLowerCase() == newItem.name.trim().toLowerCase() &&
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

      if (updatedItem.isPantry && updatedItem.expireDate != "-" && updatedItem.expireDate != "Data: N/A" && updatedItem.expireDate.isNotEmpty) {
        final otherIndex = allItems.indexWhere((i) => i.isPantry && i.id != updatedItem.id && i.name.trim().toLowerCase() == updatedItem.name.trim().toLowerCase());
        if (otherIndex != -1) {
          final otherItem = allItems[otherIndex];
          
          if (otherItem.expireDates.isEmpty && otherItem.expireDate != "-" && otherItem.expireDate != "Data: N/A" && otherItem.expireDate.isNotEmpty) {
            otherItem.expireDates.add(otherItem.expireDate);
          }
          if (updatedItem.expireDates.isEmpty && updatedItem.expireDate != "-" && updatedItem.expireDate != "Data: N/A" && updatedItem.expireDate.isNotEmpty) {
            updatedItem.expireDates.add(updatedItem.expireDate);
          }

          otherItem.quantity += updatedItem.quantity;
          otherItem.expireDates.addAll(updatedItem.expireDates);

          otherItem.expireDates.sort((a, b) {
            final pA = a.split('/');
            final pB = b.split('/');
            if (pA.length != 3 || pB.length != 3) return 0;
            final dA = DateTime(int.parse(pA[2]), int.parse(pA[1]), int.parse(pA[0]));
            final dB = DateTime(int.parse(pB[2]), int.parse(pB[1]), int.parse(pB[0]));
            return dA.compareTo(dB);
          });
          if (otherItem.expireDates.isNotEmpty) {
            otherItem.expireDate = otherItem.expireDates.first;
          }

          allItems.removeWhere((i) => i.id == updatedItem.id);
          final oIdx = allItems.indexWhere((i) => i.id == otherItem.id);
          if (oIdx != -1) allItems[oIdx] = otherItem;
          notifyListeners();

          await _firebaseService?.deleteItem(updatedItem.id);
          await _firebaseService?.saveItem(otherItem);
          return;
        }
      }

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
    for (var item in allItems
        .where((i) => i.isShopping && selectedItemIds.contains(i.id))
        .toList()) {
      final existingPantryItems = allItems.where((i) => i.isPantry && i.name.trim().toLowerCase() == item.name.trim().toLowerCase()).toList();
      ItemModel? existingWithoutExpire;
      for (var pItem in existingPantryItems) {
        if (pItem.expireDate == "-" || pItem.expireDate == "Data: N/A" || pItem.expireDate.isEmpty) {
          existingWithoutExpire = pItem;
          break;
        }
      }

      if (existingWithoutExpire != null) {
        existingWithoutExpire.quantity += item.quantity;
        if (item.ownerId != null) {
          existingWithoutExpire.ownerId = item.ownerId;
        }
        await _firebaseService?.saveItem(existingWithoutExpire);
        allItems.remove(item);
        await _firebaseService?.deleteItem(item.id);
      } else {
        item.isShopping = false;
        item.isPantry = true;
        item.expireDate = "-";
        item.expireDates = [];
        await _firebaseService?.saveItem(item);
      }
    }
    notifyListeners();
  }

  Future<void> markShoppingDone() async {
    for (var item in allItems.where((i) => i.isShopping).toList()) {
      final existingPantryItems = allItems.where((i) => i.isPantry && i.name.trim().toLowerCase() == item.name.trim().toLowerCase()).toList();
      ItemModel? existingWithoutExpire;
      for (var pItem in existingPantryItems) {
        if (pItem.expireDate == "-" || pItem.expireDate == "Data: N/A" || pItem.expireDate.isEmpty) {
          existingWithoutExpire = pItem;
          break;
        }
      }

      if (existingWithoutExpire != null) {
        existingWithoutExpire.quantity += item.quantity;
        if (item.ownerId != null) {
          existingWithoutExpire.ownerId = item.ownerId;
        }
        await _firebaseService?.saveItem(existingWithoutExpire);
        allItems.remove(item);
        await _firebaseService?.deleteItem(item.id);
      } else {
        item.isShopping = false;
        item.isPantry = true;
        item.expireDate = "-";
        item.expireDates = [];
        await _firebaseService?.saveItem(item);
      }
    }
    notifyListeners();
  }

  Future<void> updateProfileName(String newName) async {
    try {
      final user = currentUserAuth;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
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
          }
  }

  Future<void> acceptAISuggestion(String productName) async {
    final name = productName.toLowerCase().trim();
    aiFeedback.putIfAbsent(name, () => {'acceptCount': 0, 'rejectCount': 0});
    aiFeedback[name]!['acceptCount'] = (aiFeedback[name]!['acceptCount'] ?? 0) + 1;
    notifyListeners();
    await _firebaseService?.updateAIFeedback(aiFeedback);
  }

  Future<void> rejectAISuggestion(String productName) async {
    final name = productName.toLowerCase().trim();
    aiFeedback.putIfAbsent(name, () => {'acceptCount': 0, 'rejectCount': 0});
    aiFeedback[name]!['rejectCount'] = (aiFeedback[name]!['rejectCount'] ?? 0) + 1;
    notifyListeners();
    await _firebaseService?.updateAIFeedback(aiFeedback);
  }

  Future<void> addMissingIngredientsToShoppingList(List<String> ingredients) async {
    for (var ingName in ingredients) {
      final cleanName = ingName.trim();
      bool alreadyInShopping = allItems.any((i) => i.isShopping && i.name.trim().toLowerCase() == cleanName.toLowerCase());
      if (!alreadyInShopping) {
        final newItem = ItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + cleanName.hashCode.toString(),
          name: cleanName,
          expireDate: "-",
          quantity: 1,
          category: "Altro",
          isPantry: false,
          isShopping: true,
          ownerId: currentUserAuth?.uid,
        );
        allItems.add(newItem);
        await _firebaseService?.saveItem(newItem);
      }
    }
    notifyListeners();
  }
}
