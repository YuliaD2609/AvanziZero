import '../utils/snackbar_utils.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state.dart';
import '../main.dart'; // Per accedere a MainNavigator
import 'admin_screen.dart';
import '../theme/app_colors.dart';

// Schermata setup gruppo
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

  // Genera codice casuale
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final randomPart = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return 'CASA-$randomPart';
  }

  // Crea nuovo gruppo
  Future<void> _createNewGroup() async {
    final newCode = _generateRandomCode();

    // Esecuzione background
    if (widget.state.currentUserAuth != null) {
      widget.state.authService
          .addGroupToUser(widget.state.currentUserAuth!.uid, newCode);
      if (widget.state.currentUserData != null) {
        widget.state.currentUserData!.groupIds.add(newCode);
      }
    }

    await widget.state.setGroupId(newCode);

    if (!mounted) return;

    // Naviga a dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigator(state: widget.state),
      ),
    );

    // Mostra codice generato
    ScaffoldMessenger.of(context).showSmartSnackBar(
      SnackBar(
        content: Text(
          "Gruppo creato! Codice di invito: $newCode",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary, // Colore verde
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.primaryDark,
          onPressed: () {},
        ),
      ),
    );
  }

  // Unisciti a gruppo
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

    final uid = widget.state.currentUserAuth?.uid;
    final userData = widget.state.currentUserData;

    if (uid != null && userData != null) {
      // Controllo anti-spam
      if (userData.pendingGroupIds.contains(inputCode)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSmartSnackBar(
          SnackBar(
            content: Text(
                "Hai già inviato una richiesta per $inputCode. Attendi l'approvazione."),
            backgroundColor: AppColors.warning, // Colore giallo
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Controllo membro
      if (userData.groupIds.contains(inputCode)) {
        // Inizializza stato gruppo
        await widget.state.setGroupId(inputCode);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainNavigator(state: widget.state)),
        );
        return;
      }

      // Verifica esistenza gruppo
      try {
        final groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(inputCode)
            .get();
        if (!groupDoc.exists) {
          // Mostra banner eliminato
          widget.state.groupWasDeleted = true;
          // Rimuove da recenti
          widget.state.removeSavedGroup(inputCode);
          if (userData.groupIds.contains(inputCode)) {
            userData.groupIds.remove(inputCode);
          }

          setState(() {
            _isLoading = false;
          });
          return;
        }

        final members = List<String>.from(groupDoc.data()?['members'] ?? []);
        if (members.contains(uid)) {
          // Aggiunge gruppo utente
          widget.state.authService.addGroupToUser(uid, inputCode);
          userData.groupIds.add(inputCode);
          widget.state.setGroupId(inputCode);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainNavigator(state: widget.state)),
          );
          return;
        } else {
          // Invia richiesta
          await widget.state.authService
              .sendJoinRequest(uid, inputCode, userData.name, userData.email);
          userData.pendingGroupIds.add(inputCode);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSmartSnackBar(
            SnackBar(
              content: Text(
                  "Richiesta inviata! L'admin di $inputCode dovrà approvarti."),
              backgroundColor: AppColors.primary,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Errore durante l'operazione. Riprova.";
          _isLoading = false;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.groupWasDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Gruppo Eliminato",
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
            content: const Text(
              "L'amministratore ha eliminato definitivamente il gruppo. "
              "Tutti i dati sono stati cancellati.",
              style: TextStyle(fontFamily: 'Outfit'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text("Ho capito",
                    style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
          ),
        );
      });
      // Resetta flag eliminazione
      widget.state.groupWasDeleted = false;
    }

    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, child) {
        final userName = widget.state.currentUserData?.name ?? "";

        return Scaffold(
          backgroundColor: AppColors.background, // Colore sfondo
          body: SafeArea(
            child: Stack(
              children: [
                // Sfondi decorativi
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Intestazione benvenuto
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (userName.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bentornato,",
                                    style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    userName,
                                    style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary),
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminScreen(state: widget.state),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.person_outline_rounded,
                                      color: AppColors.primary, size: 28),
                                  tooltip: "Profilo",
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Logo
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),

                        // Intestazione benvenuto
                        Text(
                          "AvanziZero",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, // Colore verde scuro
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Crea o unisciti a un gruppo per iniziare a organizzare la tua dispensa!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            color: AppColors.textSecondary, // Colore salvia
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Caricamento generale
                        if (_isLoading) ...[
                          Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Sincronizzazione in tempo reale con il Cloud...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ] else ...[
                          // Banner rimosso
                          if (widget.state.userWasKicked)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person_off_rounded,
                                      color: AppColors.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Sei stato rimosso dal gruppo. Non hai più accesso ai contenuti.",
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Card crea gruppo
                          _buildCard(
                            title: "Crea un Nuovo Gruppo",
                            subtitle:
                                "Genera un codice condivisibile con i tuoi coinquilini.",
                            icon: Icons.add_home_rounded,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: _createNewGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  "Genera Codice e Inizia",
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divisore
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: AppColors.border, thickness: 1)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "OPPURE",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: AppColors.border, thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Card unisciti gruppo
                          _buildCard(
                            title: "Unisciti a un Gruppo",
                            subtitle:
                                "Hai già un codice invito? Inseriscilo qui sotto.",
                            icon: Icons.group_add_rounded,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _codeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    hintText: "Es. CASA-7B4D",
                                    hintStyle: TextStyle(
                                        color: AppColors.textSecondary),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                          color: AppColors.primary, width: 1.5),
                                    ),
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                        color: AppColors.error, fontSize: 13),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _joinExistingGroup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Text(
                                            "Entra nel Gruppo",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Pannello richieste
                                if (widget.state.currentUserData
                                        ?.pendingGroupIds.isNotEmpty ??
                                    false)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors
                                          .warningLight, // Giallo tenue
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.warning),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.hourglass_top_rounded,
                                                color: AppColors.warning,
                                                size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Richieste in Attesa",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors
                                                      .textPrimary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...widget.state.currentUserData!
                                            .pendingGroupIds
                                            .map((code) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2),
                                                  child: Text(
                                                    "• $code",
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Sezione cronologia
                          if (widget.state.savedGroups.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            Text(
                              "Gruppi Recenti",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
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
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 2),
                                    leading: Icon(Icons.history_rounded,
                                        color: AppColors.primary),
                                    title: Text(
                                      widget.state.savedGroupNames[code] ??
                                          code,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text("Codice: $code",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                    onTap: () {
                                      _codeController.text = code;
                                      _joinExistingGroup();
                                    },
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_outline_rounded,
                                          color: AppColors.error, size: 20),
                                      onPressed: () {
                                        widget.state.removeSavedGroup(code);
                                        ScaffoldMessenger.of(context)
                                            .showSmartSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Gruppo $code rimosso dalla cronologia.")),
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
              ],
            ),
          ),
        );
      },
    );
  }

  // Costruisce card
  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
