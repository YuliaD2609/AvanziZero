import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state.dart';

/// Servizio centralizzato per la gestione della persistenza e del real-time su Firebase Firestore.
/// Tutte le collezioni sono raggruppate e isolate tramite un [groupId] univoco,
/// garantendo la separazione dei dati per ciascuna casa/appartamento condiviso.
class FirebaseService {
  final String groupId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseService({required this.groupId});

  // Riferimenti alle sotto-collezioni del gruppo corrente
  CollectionReference get _itemsRef => _db.collection('groups').doc(groupId).collection('items');
  CollectionReference get _expensesRef => _db.collection('groups').doc(groupId).collection('expenses');

  // ===========================================================================
  // STREAM IN TEMPO REALE (REAL-TIME READS)
  // ===========================================================================

  /// Ascolta in tempo reale tutti i prodotti (Dispensa, Spesa, Valigia) del gruppo.
  Stream<List<ItemModel>> getItemsStream() {
    return _itemsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return ItemModel(
          id: doc.id,
          name: data['name'] ?? '',
          expireDate: data['expireDate'] ?? '-',
          quantity: data['quantity'] ?? 0,
          category: data['category'] ?? 'Tutti',
          isPantry: data['isPantry'] ?? false,
          isShopping: data['isShopping'] ?? false,
          isSuitcase: data['isSuitcase'] ?? false,
        );
      }).toList();
    });
  }

  /// Ascolta in tempo reale tutte le spese condivise dai coinquilini del gruppo.
  Stream<List<RoommateExpense>> getExpensesStream() {
    return _expensesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return RoommateExpense(
          id: doc.id,
          description: data['description'] ?? '',
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          paidBy: data['paidBy'] ?? 'Sconosciuto',
        );
      }).toList();
    });
  }

  // ===========================================================================
  // SCRITTURE (WRITES & UPDATES)
  // ===========================================================================

  /// Aggiunge o sovrascrive un prodotto su Firestore.
  Future<void> saveItem(ItemModel item) async {
    try {
      // Se l'id generato localmente è utilizzabile, lo usiamo come document ID
      final docRef = item.id.isNotEmpty ? _itemsRef.doc(item.id) : _itemsRef.doc();
      await docRef.set({
        'name': item.name,
        'expireDate': item.expireDate,
        'quantity': item.quantity,
        'category': item.category,
        'isPantry': item.isPantry,
        'isShopping': item.isShopping,
        'isSuitcase': item.isSuitcase,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Errore nel salvataggio del prodotto: $e");
    }
  }

  /// Aggiorna solo la quantità di un prodotto esistente.
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      await _itemsRef.doc(itemId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Errore nell'aggiornamento della quantità: $e");
    }
  }

  /// Elimina un prodotto dal cloud.
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemsRef.doc(itemId).delete();
    } catch (e) {
      print("Errore nell'eliminazione del prodotto: $e");
    }
  }

  /// Aggiunge una nuova spesa condivisa su Firestore.
  Future<void> addExpense(RoommateExpense expense) async {
    try {
      final docRef = expense.id.isNotEmpty ? _expensesRef.doc(expense.id) : _expensesRef.doc();
      await docRef.set({
        'description': expense.description,
        'amount': expense.amount,
        'paidBy': expense.paidBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Errore nell'aggiunta della spesa: $e");
    }
  }

  /// Sposta tutti gli articoli della Lista della Spesa in Dispensa (Spesa Fatta)
  /// utilizzando un'operazione batch atomica.
  Future<void> markShoppingDone() async {
    try {
      final snapshot = await _itemsRef.where('isShopping', isEqualTo: true).get();
      final batch = _db.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isShopping': false,
          'isPantry': true,
          'expireDate': 'Scadenza: Fresco (30 gg)',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print("Errore nel completamento della spesa: $e");
    }
  }

  /// Inizializza il gruppo con dati demo se la collezione è vuota,
  /// per garantire che l'utente veda immediatamente i prodotti iniziali al primo accesso.
  Future<void> seedInitialDataIfNeeded(List<ItemModel> initialItems, List<RoommateExpense> initialExpenses) async {
    try {
      final snapshot = await _itemsRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("Inizializzazione del gruppo $groupId con i dati di default...");
        final batch = _db.batch();
        
        for (var item in initialItems) {
          final docRef = _itemsRef.doc(item.id);
          batch.set(docRef, {
            'name': item.name,
            'expireDate': item.expireDate,
            'quantity': item.quantity,
            'category': item.category,
            'isPantry': item.isPantry,
            'isShopping': item.isShopping,
            'isSuitcase': item.isSuitcase,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        for (var exp in initialExpenses) {
          final docRef = _expensesRef.doc(exp.id);
          batch.set(docRef, {
            'description': exp.description,
            'amount': exp.amount,
            'paidBy': exp.paidBy,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        print("Dati demo inizializzati con successo su Firestore!");
      }
    } catch (e) {
      print("Errore durante il seeding iniziale: $e");
    }
  }
}
