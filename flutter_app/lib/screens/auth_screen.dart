import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

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
          if (e.code == 'user-not-found') {
            setState(() => _emailError = "Email non registrata");
            _formKey.currentState!.validate();
          } else if (e.code == 'invalid-email') {
            setState(() => _emailError = "Formato email non valido");
            _formKey.currentState!.validate();
          } else if (e.code == 'email-already-in-use') {
            setState(() => _emailError = "Questa email è già registrata");
            _formKey.currentState!.validate();
          } else if (e.code == 'wrong-password') {
            setState(() => _passwordError = "Password errata");
            _formKey.currentState!.validate();
          } else if (e.code == 'weak-password') {
            setState(() => _passwordError = "La password è troppo debole");
            _formKey.currentState!.validate();
          } else if (e.code == 'invalid-credential') {
            if (_isLogin) {
              setState(() {
                _emailError = "Credenziali non valide";
                _passwordError = "Credenziali non valide";
              });
            } else {
              setState(() => _emailError = "Credenziali non valide");
            }
            _formKey.currentState!.validate();
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
      backgroundColor: AppColors.background,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? "Bentornato! Accedi per continuare." : "Crea un account per iniziare.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
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
                      if (!_isLogin) {
                        if (val.length < 8 || 
                            !RegExp(r'[A-Z]').hasMatch(val) || 
                            !RegExp(r'[a-z]').hasMatch(val) || 
                            !RegExp(r'[!@#\$&*~_+\-\.\/\\><?\^%]').hasMatch(val) ||
                            !RegExp(r'[0-9]').hasMatch(val)) {
                          return "La password deve contenere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un carattere speciale.";
                        }
                      }
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
                  
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text("Hai dimenticato la password?", style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                    ),
                    
                  const SizedBox(height: 32),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
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
                        _emailError = null;
                        _passwordError = null;
                        // Resetta i campi e i messaggi di errore del form
                        _formKey.currentState?.reset();
                      });
                    },
                    child: Text(
                      _isLogin ? "Non hai un account? Registrati" : "Hai già un account? Accedi",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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

  void _showForgotPasswordDialog() {
    final TextEditingController emailCtrl = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Recupera Password", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Inserisci la tua email per ricevere il link di recupero password."),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Inserisci una email valida")),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await _auth.sendPasswordResetEmail(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Abbiamo inviato un link alla tua email per recuperare la password!"),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Errore: Impossibile inviare l'email di recupero.")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text("Invia"),
          ),
        ],
      ),
    );
  }
}
