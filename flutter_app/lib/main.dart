import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/app_state.dart';
import 'services/notification_service.dart';
import 'screens/group_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pantry_screen.dart';
import 'screens/shopping_screen.dart';
import 'screens/auth_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/nearby_supermarkets_modal.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Garantisce che il binding nativo di Flutter sia pronto prima dell'inizializzazione cloud
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il motore delle notifiche locali
  await NotificationService().init();

  // Caricamento variabili d'ambiente
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print(
        "Avviso: File .env non trovato. Le funzionalità API potrebbero non funzionare.");
  }

  try {
    // Inizializza Firebase nativamente usando le options generate da FlutterFire CLI
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Abilita la persistenza offline e il caching per consentire il merge locale delle modifiche
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    print("Firebase inizializzato con successo!");
  } catch (e) {
    print(
        "Avviso: Firebase non configurato nativamente ($e). Avvio in fallback locale per test UI.");
  }

  runApp(const AvanziZeroApp());
}

class AvanziZeroApp extends StatefulWidget {
  const AvanziZeroApp({super.key});

  @override
  State<AvanziZeroApp> createState() => _AvanziZeroAppState();
}

class _AvanziZeroAppState extends State<AvanziZeroApp> {
  // Gestore di stato globale istanziato alla radice
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    // Carica la cronologia dei gruppi salvati all'avvio dell'app
    _appState.loadSavedGroups();
    // Carica preferenze notifiche
    _appState.loadNotificationPreferences();
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
          scaffoldMessengerKey: rootScaffoldMessengerKey,
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
              surface: AppColors.background,
              onSurface: AppColors.textPrimary, // Verde Foresta Scuro
              brightness: globalIsDarkMode ? Brightness.dark : Brightness.light,
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
              : _appState.isInitializingUser
                  ? Scaffold(
                      backgroundColor: AppColors.background,
                      body: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  : _appState.groupId == null
                      ? GroupSetupScreen(state: _appState)
                      : _appState.isLoading
                          ? Scaffold(
                              backgroundColor: AppColors.background,
                              body: Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary),
                              ),
                            )
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
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, child) {
        // Se il gruppo viene eliminato mentre l'utente è dentro, rimandalo alla home (GroupSetupScreen)
        if (widget.state.groupId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        GroupSetupScreen(state: widget.state)),
                (Route<dynamic> route) => false,
              );
            }
          });
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)));
        }

        // Array delle 3 schermate principali con i riferimenti incrociati di navigazione
        final List<Widget> screens = [
          HomeScreen(
            state: widget.state,
            onNavigate: _navigate,
            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
          PantryScreen(
            state: widget.state,
            onHomePressed: () => _navigate(0),
            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
          ShoppingScreen(
            state: widget.state,
            onHomePressed: () => _navigate(0),
            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
        ];

        return PopScope(
            canPop: _currentIndex == 0,
            onPopInvoked: (didPop) {
              if (didPop) return;
              if (_currentIndex != 0) {
                _navigate(0);
              }
            },
            child: Scaffold(
              body: screens[_currentIndex],

              // Barra di navigazione inferiore fluida e moderna
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowNavbar,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _navigate,
                  backgroundColor: AppColors.surfaceLight,
                  indicatorColor:
                      AppColors.primaryLight, // Menta Chiaro per tab attiva
                  elevation: 0,
                  height: 65,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined,
                          color: AppColors.textSecondary),
                      selectedIcon:
                          Icon(Icons.home_rounded, color: AppColors.primary),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.kitchen_outlined,
                          color: AppColors.textSecondary),
                      selectedIcon:
                          Icon(Icons.kitchen_rounded, color: AppColors.primary),
                      label: 'Dispensa',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined,
                          color: AppColors.textSecondary),
                      selectedIcon: Icon(Icons.receipt_long_rounded,
                          color: AppColors.primary),
                      label: 'Spesa',
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

}
