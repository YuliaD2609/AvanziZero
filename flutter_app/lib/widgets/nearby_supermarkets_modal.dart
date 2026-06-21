import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import '../services/supermarkets_service.dart';

void showNearbySupermarketsModal(BuildContext context, AppState state) {
  int selectedIndex = -1;
  bool isLoading = true;
  bool hasStartedFetching = false;
  bool locationError = false;

  void fetchSupermarkets(Function setModalState) {
    setModalState(() {
      isLoading = true;
      locationError = false;
    });
    SupermarketsService.fetchNearby(context).then((results) {
      if (context.mounted) {
        setModalState(() {
          if (results != null) {
            state.nearbySupermarkets = results;
            locationError = false;
          } else {
            locationError = true;
          }
          isLoading = false;
        });
      }
    });
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // Impedisce overflow su schermi ridotti
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        if (!hasStartedFetching) {
          hasStartedFetching = true;
          fetchSupermarkets(setModalState);
        }

        Widget contentWidget;
        if (isLoading) {
          contentWidget = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text("Ricerca supermercati nel raggio di 5km...",
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        } else if (locationError) {
          contentWidget = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off_rounded,
                    size: 40, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                    "Attiva la posizione per vedere i supermercati nelle vicinanze",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => fetchSupermarkets(setModalState),
                  icon:
                      const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text("Riprova",
                      style: TextStyle(
                          color: AppColors.surfaceLight,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
          );
        } else if (state.nearbySupermarkets.isEmpty) {
          contentWidget = Center(
              child: Text("Nessun supermercato trovato nei paraggi.",
                  style: TextStyle(color: AppColors.textSecondary)));
        } else {
          contentWidget = ListView.builder(
            shrinkWrap: true,
            itemCount: state.nearbySupermarkets.length,
            itemBuilder: (context, index) {
              final s = state.nearbySupermarkets[index];
              final isSelected = selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setModalState(() {
                      selectedIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimary
                                          .withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.address,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.border.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.distance,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.85, // Lascia un margine superiore visibile
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intestazione
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront_rounded,
                          color: AppColors.primaryDark, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "Supermercati Vicini",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Seleziona il supermercato desiderato per avviare la navigazione in Google Maps:",
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),

              // Lista scrollabile o Errore
              Expanded(child: contentWidget),

              const SizedBox(height: 12),

              // Pulsante di avvio in Maps
              ElevatedButton.icon(
                onPressed: () async {
                  String query;
                  if (selectedIndex == -1 ||
                      state.nearbySupermarkets.isEmpty) {
                    query = "supermercati";
                  } else {
                    final selectedSupermarket =
                        state.nearbySupermarkets[selectedIndex];
                    query =
                        "${selectedSupermarket.name} ${selectedSupermarket.address}";
                  }

                  final encodedQuery = Uri.encodeComponent(query);
                  final mapsUrl = Uri.parse(
                      "https://www.google.com/maps/search/?api=1&query=$encodedQuery");

                  Navigator.pop(context);

                  try {
                    await launchUrl(mapsUrl,
                        mode: LaunchMode.externalApplication);
                  } catch (e) {
                                        if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Impossibile avviare Google Maps. Verifica la connessione o l'app installata.")),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.map_rounded, size: 20),
                label: const Text(
                  "Apri in Google Maps",
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryDark, // Accento Verde Scuro/Teal
                  foregroundColor:
                      Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
