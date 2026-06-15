import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';
  String _name = '';

  String? _emailError;
  String? _passwordError;

  void _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        if (_isLogin) {
          await _auth.signInWithEmailAndPassword(_email.trim(), _password.trim());
        } else {
          await _auth.registerWithEmailAndPassword(_email.trim(), _password.trim(), _name.trim());
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          if (e.code == 'user-not-found' || e.code == 'invalid-email') {
            setState(() {
              _emailError = "Email non registrata";
            });
            _formKey.currentState!.validate();
          } else if (e.code == 'wrong-password') {
            setState(() {
              _passwordError = "Password errata";
            });
            _formKey.currentState!.validate();
          } else if (e.code == 'invalid-credential') {
            bool checked = false;
            // 1. Prova con fetchSignInMethodsForEmail (FirebaseAuth)
            try {
              final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_email.trim());
              setState(() {
                if (methods.isEmpty) {
                  _emailError = "Email non registrata";
                } else {
                  _passwordError = "Password errata";
                }
              });
              _formKey.currentState!.validate();
              checked = true;
            } catch (_) {}

            // 2. Se fallisce, prova con query Firestore
            if (!checked) {
              try {
                final query = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: _email.trim())
                    .limit(1)
                    .get();
                setState(() {
                  if (query.docs.isEmpty) {
                    _emailError = "Email non registrata";
                  } else {
                    _passwordError = "Password errata";
                  }
                });
                _formKey.currentState!.validate();
                checked = true;
              } catch (_) {}
            }

            // 3. Fallback finale: se entrambi falliscono, colora entrambi i campi in rosso
            if (!checked) {
              setState(() {
                _emailError = "Email non registrata";
                _passwordError = "Password errata";
              });
              _formKey.currentState!.validate();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? "Errore di autenticazione")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim())),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 180,
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "AvanziZero",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C3D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? "Bentornato! Accedi per continuare." : "Crea un account per iniziare.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF789088),
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!_isLogin)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Nome",
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (val) => val == null || val.isEmpty ? "Inserisci il tuo nome" : null,
                      onSaved: (val) => _name = val!,
                    ),
                  if (!_isLogin) const SizedBox(height: 16),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (_emailError != null) return _emailError;
                      if (val == null || !val.contains('@')) return "Inserisci una email valida";
                      return null;
                    },
                    onChanged: (val) {
                      if (_emailError != null) {
                        setState(() {
                          _emailError = null;
                        });
                      }
                    },
                    onSaved: (val) => _email = val!,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (val) {
                      if (_passwordError != null) return _passwordError;
                      if (val == null || val.isEmpty) return "Inserisci la password";
                      if (!_isLogin && val.length < 6) return "La password deve avere almeno 6 caratteri";
                      return null;
                    },
                    onChanged: (val) {
                      if (_passwordError != null) {
                        setState(() {
                          _passwordError = null;
                        });
                      }
                    },
                    onSaved: (val) => _password = val!,
                  ),
                  const SizedBox(height: 32),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A9E87)))
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A9E87),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _isLogin ? "Accedi" : "Registrati",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Resetta i campi e i messaggi di errore del form
                        _formKey.currentState?.reset();
                      });
                    },
                    child: Text(
                      _isLogin ? "Non hai un account? Registrati" : "Hai già un account? Accedi",
                      style: const TextStyle(color: Color(0xFF5A9E87), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
