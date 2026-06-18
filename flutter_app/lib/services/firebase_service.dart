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


  // ===========================================================================
  // STREAM IN TEMPO REALE (REAL-TIME READS)
  // ===========================================================================

  /// Ascolta in tempo reale tutti i prodotti (Dispensa, Spesa) del gruppo.
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
          ownerId: data['ownerId'],
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
        'ownerId': item.ownerId,
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

  /// Inizializza un nuovo gruppo con dati demo se vuoto
  Future<void> seedInitialDataIfNeeded(List<ItemModel> initialItems, {String? uid}) async {
    try {
      // Assicura che il documento del gruppo esista per poterlo vedere chiaramente nel db
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        await _db.collection('groups').doc(groupId).set({
          'createdAt': FieldValue.serverTimestamp(),
          'code': groupId,
          'adminIds': uid != null ? [uid] : [],
          'members': uid != null ? [uid] : [],
        });
      }

      final itemsSnap = await _itemsRef.limit(1).get();
      if (itemsSnap.docs.isEmpty) {
        // Popola Articoli
        for (var item in initialItems) {
          final docRef = _itemsRef.doc(item.id);
          await docRef.set({
            'name': item.name,
            'expireDate': item.expireDate,
            'quantity': item.quantity,
            'category': item.category,
            'isPantry': item.isPantry,
            'isShopping': item.isShopping,
          });
        }
      }
    } catch (e) {
      print("Errore nel seeding iniziale: $e");
    }
  }
  Stream<DocumentSnapshot> getGroupStream() {
    return _db.collection('groups').doc(groupId).snapshots();
  }

  Future<void> updateCategories(List<String> categories) async {
    try {
      await _db.collection('groups').doc(groupId).set({
        'categories': categories,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Errore aggiornamento categorie: $e");
    }
  }

  /// Elimina definitivamente il gruppo e tutti i suoi dati (wipe completo)
  Future<void> deleteGroup() async {
    try {
      // 1. Elimina tutti i documenti nella subcollection 'items'
      final itemsSnap = await _itemsRef.get();
      final batch = _db.batch();
      for (var doc in itemsSnap.docs) {
        batch.delete(doc.reference);
      }
      // Esegui il batch per cancellare gli items
      await batch.commit();

      // 2. Elimina il documento del gruppo
      await _db.collection('groups').doc(groupId).delete();
    } catch (e) {
      print("Errore nell'eliminazione del gruppo: $e");
    }
  }
}
