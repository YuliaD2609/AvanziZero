import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state.dart';

// Gestisce Firebase Firestore
class FirebaseService {
  final String groupId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseService({required this.groupId});

  // Definisce riferimenti alle collezioni
  CollectionReference get _itemsRef =>
      _db.collection('groups').doc(groupId).collection('items');

  // Letture in tempo reale

  // Ascolta prodotti in tempo reale
  Stream<List<ItemModel>> getItemsStream() {
    return _itemsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return ItemModel(
          id: doc.id,
          name: data['name'] ?? '',
          expireDate: data['expireDate'] ?? '-',
          expireDates: (data['expireDates'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
          quantity: data['quantity'] ?? 0,
          category: data['category'] ?? 'Tutti',
          isPantry: data['isPantry'] ?? false,
          isShopping: data['isShopping'] ?? false,
          ownerId: data['ownerId'],
        );
      }).toList();
    });
  }

  // Scritture e aggiornamenti

  // Salva un prodotto
  Future<void> saveItem(ItemModel item) async {
    try {
      // Usa ID generato localmente
      final docRef =
          item.id.isNotEmpty ? _itemsRef.doc(item.id) : _itemsRef.doc();
      await docRef.set({
        'name': item.name,
        'expireDate': item.expireDate,
        'expireDates': item.expireDates,
        'quantity': item.quantity,
        'category': item.category,
        'isPantry': item.isPantry,
        'isShopping': item.isShopping,
        'ownerId': item.ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
          }
  }

  // Aggiorna la quantità
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      await _itemsRef.doc(itemId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
          }
  }

  // Elimina un prodotto
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemsRef.doc(itemId).delete();
    } catch (e) {
          }
  }



  // Inizializza gruppo vuoto
  Future<void> seedInitialDataIfNeeded(List<ItemModel> initialItems,
      {String? uid}) async {
    try {
      // Crea documento del gruppo
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
        // Popola articoli iniziali
        for (var item in initialItems) {
          final docRef = _itemsRef.doc(item.id);
          await docRef.set({
            'name': item.name,
            'expireDate': item.expireDate,
            'expireDates': item.expireDates,
            'quantity': item.quantity,
            'category': item.category,
            'isPantry': item.isPantry,
            'isShopping': item.isShopping,
          });
        }
      }
    } catch (e) {
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
          }
  }

  Future<void> updateAIFeedback(Map<String, Map<String, int>> aiFeedback) async {
    try {
      await _db.collection('groups').doc(groupId).set({
        'aiFeedback': aiFeedback,
      }, SetOptions(merge: true));
    } catch (e) {
    }
  }

  // Elimina gruppo definitivamente
  Future<void> deleteGroup() async {
    try {
      // Elimina articoli
      final itemsSnap = await _itemsRef.get();
      final batch = _db.batch();
      for (var doc in itemsSnap.docs) {
        batch.delete(doc.reference);
      }
      // Esegue il batch
      await batch.commit();

      // Elimina documento gruppo
      await _db.collection('groups').doc(groupId).delete();
    } catch (e) {
          }
  }

  // Registra consumo prodotto
  Future<void> logConsumption(String itemName, int quantityConsumed) async {
    try {
      final docRef = _db
          .collection('groups')
          .doc(groupId)
          .collection('consumption_history')
          .doc();
      await docRef.set({
        'name': itemName,
        'quantity': quantityConsumed,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
          }
  }

  // Recupera storico consumi
  Future<List<Map<String, dynamic>>> getConsumptionHistory() async {
    try {
      final snap = await _db
          .collection('groups')
          .doc(groupId)
          .collection('consumption_history')
          .get();

      // Ordina i log in locale
      final docs = snap.docs.map((d) => d.data()).toList();
      return docs;
    } catch (e) {
            return [];
    }
  }
}
