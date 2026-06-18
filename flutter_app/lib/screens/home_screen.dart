import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/ocr_scanner_modal.dart';
import '../widgets/menus.dart';
import 'admin_screen.dart';
import 'group_setup_screen.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  final Function(int) onNavigate;
  final VoidCallback onCartPressed;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigate,
    required this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Identifica i prodotti in scadenza per il warningLayout
    final expiringItems = state.allItems.where((i) => i.isPantry && i.urgencyLevel > 0).toList();

    return Scaffold(
      backgroundColor: AppColors.background, // Avorio soft
      
      // Rimosso FAB come richiesto, l'IA scanner è stato spostato in Dispensa

      body: Column(
        children: [
          HorizontalHeaderMenu(
            title: "AvanziZero",
            onHomePressed: () {},
            onCartPressed: onCartPressed,
            showHome: false,
            leftAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 28),
                  tooltip: "Area Admin",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(state: state),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner premium del Gruppo Casa Attivo con opzione di Uscita
              if (state.groupId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight, // Menta Chiaro
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.maps_home_work_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Gruppo: ${state.groupId}",
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Uscita istantanea dal gruppo corrente
                              state.leaveGroup();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => GroupSetupScreen(state: state)),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                            label: const Text(
                              "Esci",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
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
                    ],
                  ),
                ),

              // Logo / Titolo (Sostituisce l'ImageView logo_text in modo premium)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Transform.scale(
                      scale: 1.1,
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "AvanziZero",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary, // Verde Salvia Intenso
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tutto quello che serve dalla A alla Z.",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: AppColors.textPrimary.withOpacity(0.7),
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
                  border: Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Intestazione con la scritta esatta nativa "Prodotti in scadenza"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.errorLight, // Sfondo rosso chiaro
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                      ),
                      child: const Text(
                        "Prodotti in scadenza",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    
                    // Contenitore lista in scadenza (warningContainer)
                    Expanded(
                      child: expiringItems.isEmpty
                          ? const Center(
                              child: Text(
                                "Nessun prodotto in scadenza!",
                                style: TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.bold),
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
                                        style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        _formatExpireDate(item.expireDate),
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          color: item.urgencyLevel == 2 ? AppColors.error : AppColors.textSecondary,
                                          fontWeight: item.urgencyLevel > 0 ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "I supermercati nelle vicinanze sono consultabili in qualsiasi momento dall'icona negozio in alto a destra.",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
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
    ],
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
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowMedium, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }

  // Formatta la data di scadenza calcolando la data effettiva se indicata come "tra X giorni"
  String _formatExpireDate(String text) {
    String cleanText = text.replaceAll("In scadenza: ", "").replaceAll("Scadenza: ", "").trim();
    if (cleanText == "-" || cleanText.isEmpty) {
      return "-";
    }

    // Controlla se è nel formato gg/mm/aaaa
    final dateParts = cleanText.split('/');
    if (dateParts.length == 3) {
      final day = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);
      if (day != null && month != null && year != null) {
        final expDate = DateTime(year, month, day);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final difference = expDate.difference(today).inDays;
        
        if (difference == 0) return 'Oggi';
        if (difference == 1) return 'Domani';
        return cleanText;
      }
    }

    if (cleanText.toLowerCase().contains('oggi')) return 'Oggi';
    if (cleanText.toLowerCase().contains('domani')) return 'Domani';
    
    final match = RegExp(r'tra (\d+) giorn[io]').firstMatch(cleanText);
    if (match != null) {
      final days = int.parse(match.group(1)!);
      if (days == 0) return 'Oggi';
      if (days == 1) return 'Domani';
      
      final date = DateTime.now().add(Duration(days: days));
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }
    
    return cleanText;
  }
}
