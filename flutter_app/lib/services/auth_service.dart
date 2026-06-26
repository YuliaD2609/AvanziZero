import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthService() {
    // Disabilita controlli di sicurezza in locale
    _auth.setSettings(appVerificationDisabledForTesting: true);
  }

  // Definisce stream autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Restituisce utente corrente
  User? get currentUser => _auth.currentUser;

  Future<void> _disableRecaptcha() async {
    await _auth.setSettings(appVerificationDisabledForTesting: true);
  }

  // Registra nuovo utente
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      await _disableRecaptcha();
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Crea documento utente
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          groupIds: [], // Inizializza gruppi vuoti
        );

        await _db.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return null;
    } catch (e) {
            rethrow;
    }
  }

  // Effettua il login
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

  // Recupera dati utente
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

  // Aggiunge gruppo all'utente
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
      // Aggiunge gruppo a richieste in sospeso
      await _db.collection('users').doc(uid).update({
        'pendingGroupIds': FieldValue.arrayUnion([groupId])
      });
      // Crea documento richiesta
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

  // Effettua il logout
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
            return;
    }
  }

  // Invia reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
            rethrow;
    }
  }
}
