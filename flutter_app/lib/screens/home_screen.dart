import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/ocr_scanner_modal.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // Identifica i prodotti in scadenza per il warningLayout
    final expiringItems = state.allItems.where((i) => i.isPantry && i.urgencyLevel > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9), // Avorio soft
      
      // Rimosso FAB come richiesto, l'IA scanner è stato spostato in Dispensa

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra Superiore (Icona cestino e Notifiche)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF789088)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nessun elemento nel cestino.")),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF789088)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nessuna notifica.")),
                      );
                    },
                  ),
                ],
              ),

              // Banner premium del Gruppo Casa Attivo con opzione di Uscita
              if (state.groupId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5), // Menta Chiaro
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF5A9E87).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.maps_home_work_rounded, color: Color(0xFF5A9E87), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Gruppo: ${state.groupId}",
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C3D32),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Uscita istantanea dal gruppo corrente
                          state.leaveGroup();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Sei uscito dal gruppo appartamento.")),
                          );
                        },
                        icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFEF4444)),
                        label: const Text(
                          "Esci",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),

              // Logo / Titolo (Sostituisce l'ImageView logo_text in modo premium)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "AvanziZero",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5A9E87), // Verde Salvia Intenso
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Gestione Casa e Dispensa Fuorisede",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: const Color(0xFF1C3D32).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===============================================================
              // PULSANTI PRINCIPALI (Lasciati esattamente con le scritte originali)
              // ===============================================================
              
              // 1. Lista della spesa
              _buildMainNavigationButton(
                title: "Lista della spesa",
                iconData: Icons.receipt_long_rounded,
                onTap: () => onNavigate(2),
              ),
              const SizedBox(height: 16),

              // 2. Dispensa
              _buildMainNavigationButton(
                title: "Dispensa",
                iconData: Icons.kitchen_rounded,
                onTap: () => onNavigate(1),
              ),
              const SizedBox(height: 20),

              // ===============================================================
              // SEZIONE WARNING: PRODOTTI IN SCADENZA (warningLayout)
              // ===============================================================
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x051C3D32), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Intestazione con la scritta esatta nativa "Prodotti in scadenza"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2), // Sfondo rosso chiaro
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                      ),
                      child: const Text(
                        "Prodotti in scadenza",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    
                    // Contenitore lista in scadenza (warningContainer)
                    Expanded(
                      child: expiringItems.isEmpty
                          ? const Center(
                              child: Text(
                                "Nessun prodotto in scadenza! 🎉",
                                style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF5A9E87), fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: expiringItems.length,
                              itemBuilder: (context, index) {
                                final item = expiringItems[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "• ${item.name}",
                                        style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: Color(0xFF1C3D32)),
                                      ),
                                      Text(
                                        _formatExpireDate(item.expireDate),
                                        style: const TextStyle(fontFamily: 'Outfit', color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nota informativa di orientamento (i supermercati sono spostati nel carrello in alto a destra)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAECE8)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF789088), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "I supermercati nelle vicinanze sono consultabili in qualsiasi momento dall'icona negozio in alto a destra.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF789088), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              // Spazio per il FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Costruisce i bottoni principali replicando il design con i bordi e l'icona a sinistra
  Widget _buildMainNavigationButton({
    required String title,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 70, // Altezza generosa simile al 60dp nativo
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF5A9E87), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x081C3D32), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBF9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: const Color(0xFF5A9E87), size: 26),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C3D32),
                ),
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Color(0xFF5A9E87), size: 28),
          ],
        ),
      ),
    );
  }

  // Formatta la data di scadenza calcolando la data effettiva se indicata come "tra X giorni"
  String _formatExpireDate(String text) {
    if (text.contains('Oggi')) return 'Oggi';
    if (text.contains('Domani')) return 'Domani';
    
    final match = RegExp(r'tra (\d+) giorni').firstMatch(text);
    if (match != null) {
      final days = int.parse(match.group(1)!);
      final date = DateTime.now().add(Duration(days: days));
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }
    
    return text.replaceAll("In scadenza: ", "").replaceAll("Scadenza: ", "");
  }
}
