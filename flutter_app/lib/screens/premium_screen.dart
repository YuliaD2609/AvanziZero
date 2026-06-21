import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header compatto
            Stack(
              children: [
                Container(
                  height: 130, // Altezza ridotta
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 48, // Icona rimpicciolita
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Passa a Premium!',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 24, // Testo rimpicciolito
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Per te tanti vantaggi:',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Lista dei vantaggi (distribuiti uniformemente nello spazio per non scrollare)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPremiumFeature(
                      icon: Icons.groups_rounded,
                      title: 'Gruppi Allargati',
                      description: 'Condivisione di gruppi da 3 persone in su.',
                    ),
                    _buildPremiumFeature(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notifiche Personalizzate',
                      description: 'Imposta promemoria per più orari diversi.',
                    ),
                    _buildPremiumFeature(
                      icon: Icons.people_alt_rounded,
                      title: 'Più Gruppi Insieme',
                      description: 'Fai parte di più di 2 gruppi in contemporanea.',
                    ),
                    _buildPremiumFeature(
                      icon: Icons.insights_rounded,
                      title: 'Statistiche Avanzate',
                      description: 'Analizza le tue spese e abitudini mensili.',
                    ),
                    _buildPremiumFeature(
                      icon: Icons.receipt_long_rounded,
                      title: 'Scansione Scontrini Illimitata',
                      description: 'Aggiungi scontrini senza limite (vs 2/mese).',
                    ),
                    _buildPremiumFeature(
                      icon: Icons.block_rounded,
                      title: 'Nessuna Pubblicità',
                      description: 'Goditi un\'esperienza fluida senza interruzioni.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pulsante CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Abbonati a 2,99€ / mese',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            TextButton(
              onPressed: () {},
              child: Text(
                'Forse più tardi',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
