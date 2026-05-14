import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../main.dart'; // Per accedere a MainNavigator

/// Schermata iniziale ordinata ed elegante per la configurazione del gruppo casa.
/// Permette di avviare un nuovo ambiente di co-living generando un codice univoco,
/// oppure di collegarsi istantaneamente alla dispensa e spese di coinquilini esistenti
/// inserendo il codice di condivisione, con gestione della cronologia gruppi visitati.
class GroupSetupScreen extends StatefulWidget {
  final AppState state;

  const GroupSetupScreen({super.key, required this.state});

  @override
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends State<GroupSetupScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Genera un codice casa casuale, semplice e facilmente condivisibile (es. "CASA-7B4D")
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final randomPart = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return 'CASA-$randomPart';
  }

  /// Flusso di creazione di un nuovo gruppo domestico
  Future<void> _createNewGroup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final newCode = _generateRandomCode();
    await widget.state.setGroupId(newCode);

    if (!mounted) return;

    // Naviga alla dashboard principale
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigator(state: widget.state),
      ),
    );

    // Mostra il codice generato in una comoda notifica visiva
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🏠 Gruppo creato! Codice di invito: $newCode",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5A9E87), // Verde Salvia Intenso
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'OK',
          textColor: const Color(0xFFFFB088),
          onPressed: () {},
        ),
      ),
    );
  }

  /// Flusso di unione a un gruppo domestico esistente tramite immissione codice
  Future<void> _joinExistingGroup() async {
    final inputCode = _codeController.text.trim().toUpperCase();
    
    if (inputCode.isEmpty) {
      setState(() {
        _errorMessage = "Inserisci un codice valido per continuare.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await widget.state.setGroupId(inputCode);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigator(state: widget.state),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🔗 Collegato con successo al gruppo: $inputCode"),
        backgroundColor: const Color(0xFF5A9E87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBFBF9), // Avorio Soft
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / Icona premium
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5A9E87), Color(0xFF76B59D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5A9E87).withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.maps_home_work_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),

                    // Intestazione di Benvenuto
                    const Text(
                      "FarFromHome",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C3D32), // Verde Foresta Scuro
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Lontano da casa, ma organizzato.\nCrea o unisciti a un gruppo per condividere dispensa e spese.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        color: Color(0xFF789088), // Salvia Desaturato
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Visualizzazione di caricamento generale
                    if (_isLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(color: Color(0xFF5A9E87)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Sincronizzazione in tempo reale con il Cloud...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF789088), fontSize: 14),
                      ),
                    ] else ...[
                      // Card 1: Crea un Nuovo Gruppo
                      _buildCard(
                        title: "Crea un Nuovo Gruppo",
                        subtitle: "Genera un codice condivisibile con i tuoi coinquilini.",
                        icon: Icons.add_home_rounded,
                        child: ElevatedButton(
                          onPressed: _createNewGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A9E87), // Verde Salvia Intenso
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Genera Codice e Inizia",
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divisore grafico
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFEAECE8), thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OPPURE",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF789088)),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFEAECE8), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Card 2: Unisciti a un Gruppo Esistente
                      _buildCard(
                        title: "Unisciti a un Gruppo",
                        subtitle: "Hai già un codice invito? Inseriscilo qui sotto.",
                        icon: Icons.group_add_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: "Es. CASA-7B4D",
                                hintStyle: const TextStyle(color: Color(0xFF789088)),
                                filled: true,
                                fillColor: const Color(0xFFFBFBF9),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFEAECE8)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFEAECE8)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF5A9E87), width: 2),
                                ),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C3D32)),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                              ),
                            ],
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _joinExistingGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB088), // Accento Pesca Pastello
                                foregroundColor: const Color(0xFF1C3D32),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                "Accedi al Gruppo",
                                style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sezione Cronologia: Gruppi Visitati Di Recente
                      if (widget.state.savedGroups.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          "Gruppi Recenti",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF789088),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.state.savedGroups.length,
                          itemBuilder: (context, index) {
                            final code = widget.state.savedGroups[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEAECE8)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                leading: const Icon(Icons.history_rounded, color: Color(0xFF5A9E87)),
                                title: Text(
                                  code,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C3D32),
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: const Text("Tocca per accedere", style: TextStyle(fontSize: 12, color: Color(0xFF789088))),
                                onTap: () {
                                  _codeController.text = code;
                                  _joinExistingGroup();
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                  onPressed: () {
                                    widget.state.removeSavedGroup(code);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Gruppo $code rimosso dalla cronologia.")),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Costruisce una scheda elegante e modulare conforme al Design System
  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1C3D32), // 5% di opacità per un'ombra morbida e naturale
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF5A9E87), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C3D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: Color(0xFF789088),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
