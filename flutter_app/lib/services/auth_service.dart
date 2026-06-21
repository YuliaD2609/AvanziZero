import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthService() {
    // Workaround per gli emulatori: disabilita il controllo Play Integrity / reCAPTCHA
    // che causa l'errore CONFIGURATION_NOT_FOUND in locale.
    _auth.setSettings(appVerificationDisabledForTesting: true);
  }

  // Stream per ascoltare i cambiamenti di stato dell'autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Restituisce l'utente corrente o null
  User? get currentUser => _auth.currentUser;

  Future<void> _disableRecaptcha() async {
    await _auth.setSettings(appVerificationDisabledForTesting: true);
  }

  // Registrazione con Email e Password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      await _disableRecaptcha();
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Creazione del documento utente in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          groupIds: [], // Nessun gruppo alla registrazione
        );

        await _db.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return null;
    } catch (e) {
            rethrow;
    }
  }

  // Login con Email e Password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _disableRecaptcha();
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        return await getUserData(user.uid);
      }
      return null;
    } catch (e) {
            rethrow;
    }
  }

  // Recupera i dati dell'utente dal DB
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Aggiunge un gruppo all'utente
  Future<void> addGroupToUser(String uid, String groupId) async {
    try {
      await _db.collection('users').doc(uid).update({
        'groupIds': FieldValue.arrayUnion([groupId])
      });
    } catch (e) {
            rethrow;
    }
  }

  // Invia richiesta di accesso
  Future<void> sendJoinRequest(
      String uid, String groupId, String name, String email) async {
    try {
      // 1. Aggiungi il gruppo nei pendingGroupIds dell'utente
      await _db.collection('users').doc(uid).update({
        'pendingGroupIds': FieldValue.arrayUnion([groupId])
      });
      // 2. Crea il documento richiesta
      await _db
          .collection('groups')
          .doc(groupId)
          .collection('requests')
          .doc(uid)
          .set({
        'id': uid,
        'name': name,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
            rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
            return;
    }
  }

  // Recupero Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
            rethrow;
    }
  }
}
