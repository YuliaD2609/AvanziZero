import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/app_state.dart';
import 'services/supermarkets_service.dart';
import 'screens/group_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pantry_screen.dart';
import 'screens/shopping_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  // Garantisce che il binding nativo di Flutter sia pronto prima dell'inizializzazione cloud
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inizializza Firebase nativamente usando le options generate da FlutterFire CLI
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inizializzato con successo!");
  } catch (e) {
    print("Avviso: Firebase non configurato nativamente ($e). Avvio in fallback locale per test UI.");
  }

  runApp(const FarFromHomeApp());
}

class FarFromHomeApp extends StatefulWidget {
  const FarFromHomeApp({super.key});

  @override
  State<FarFromHomeApp> createState() => _FarFromHomeAppState();
}

class _FarFromHomeAppState extends State<FarFromHomeApp> {
  // Gestore di stato globale istanziato alla radice
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    // Carica la cronologia dei gruppi salvati all'avvio dell'app
    _appState.loadSavedGroups();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'AvanziZero',
          debugShowCheckedModeBanner: false,
          
          // Tema globale basato sui token Pastel Sage & Soft Mint
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColors.primary, // Verde Salvia Intenso
            scaffoldBackgroundColor: AppColors.background, // Avorio Soft
            fontFamily: 'Outfit',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.primaryDark, // Verde Scuro/Teal
              surface: Colors.white,
              onSurface: AppColors.textPrimary, // Verde Foresta Scuro
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          
          // Routing dinamico basato sull'autenticazione e sul Codice Gruppo
          home: _appState.currentUserAuth == null
              ? const AuthScreen()
              : _appState.groupId == null
                  ? GroupSetupScreen(state: _appState)
                  : MainNavigator(state: _appState),
        );
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  final AppState state;

  const MainNavigator({super.key, required this.state});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  void _navigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Array delle 3 schermate principali con i riferimenti incrociati di navigazione
    final List<Widget> screens = [
      HomeScreen(
        state: widget.state,
        onNavigate: _navigate,
        onCartPressed: () => _showNearbySupermarketsModal(context),
      ),
      PantryScreen(
        state: widget.state,
        onHomePressed: () => _navigate(0),
        onCartPressed: () => _showNearbySupermarketsModal(context),
      ),
      ShoppingScreen(
        state: widget.state,
        onHomePressed: () => _navigate(0),
        onCartPressed: () => _showNearbySupermarketsModal(context),
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Se non siamo nella Dashboard, torna alla Dashboard invece di chiudere l'app
        if (_currentIndex != 0) {
          _navigate(0);
          return false;
        }
        // Se siamo nella Dashboard, chiudi l'app normalmente
        return true;
      },
      child: Scaffold(
        body: screens[_currentIndex],
        
        // Barra di navigazione inferiore fluida e moderna
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowNavbar,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigate,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight, // Menta Chiaro per tab attiva
          elevation: 0,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.kitchen_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.kitchen_rounded, color: AppColors.primary),
              label: 'Dispensa',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              label: 'Spesa',
            ),
          ],
        ),
      ),
    ));
  }

  // Finestra di ricerca automatica supermercati con scorrimento e integrazione Maps nativa
  void _showNearbySupermarketsModal(BuildContext context) {
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
              widget.state.nearbySupermarkets = results;
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
            contentWidget = const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text("Ricerca supermercati nel raggio di 5km...", style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          } else if (locationError) {
            contentWidget = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off_rounded, size: 40, color: AppColors.error),
                  const SizedBox(height: 12),
                  const Text("Attiva la posizione per vedere i supermercati nelle vicinanze", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => fetchSupermarkets(setModalState),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text("Riprova", style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              ),
            );
          } else if (widget.state.nearbySupermarkets.isEmpty) {
            contentWidget = const Center(child: Text("Nessun supermercato trovato nei paraggi.", style: TextStyle(color: AppColors.textSecondary)));
          } else {
            contentWidget = ListView.builder(
              shrinkWrap: true,
              itemCount: widget.state.nearbySupermarkets.length,
              itemBuilder: (context, index) {
                final s = widget.state.nearbySupermarkets[index];
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
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
                                    color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.address,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.border.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.distance,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
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
              maxHeight: MediaQuery.of(context).size.height * 0.85, // Lascia un margine superiore visibile
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Intestazione
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storefront_rounded, color: AppColors.primaryDark, size: 28),
                        SizedBox(width: 10),
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
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Seleziona il supermercato desiderato per avviare la navigazione in Google Maps:",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                    if (selectedIndex == -1 || widget.state.nearbySupermarkets.isEmpty) {
                      query = "supermercati";
                    } else {
                      final selectedSupermarket = widget.state.nearbySupermarkets[selectedIndex];
                      query = "${selectedSupermarket.name} ${selectedSupermarket.address}";
                    }
                    
                    final encodedQuery = Uri.encodeComponent(query);
                    final mapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedQuery");

                    Navigator.pop(context);

                    try {
                      await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print("Impossibile aprire Google Maps: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Impossibile avviare Google Maps. Verifica la connessione o l'app installata.")),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: const Text(
                    "Apri in Google Maps",
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark, // Accento Verde Scuro/Teal
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
