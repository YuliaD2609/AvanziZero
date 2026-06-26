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
import 'screens/recipes_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/nearby_supermarkets_modal.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Inizializza i binding di Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza le notifiche locali
  await NotificationService().init();

  // Carica le variabili di ambiente
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
      }

  try {
    // Inizializza Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Abilita la persistenza offline
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

      } catch (e) {
      }

  runApp(const AvanziZeroApp());
}

class AvanziZeroApp extends StatefulWidget {
  const AvanziZeroApp({super.key});

  @override
  State<AvanziZeroApp> createState() => _AvanziZeroAppState();
}

class _AvanziZeroAppState extends State<AvanziZeroApp> {
  // Gestore dello stato globale
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    // Carica i gruppi salvati
    _appState.loadSavedGroups();
    // Carica le preferenze notifiche
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

          // Configura il tema globale
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Outfit',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.primaryDark,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
              brightness: globalIsDarkMode ? Brightness.dark : Brightness.light,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          // Configura il routing dinamico
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
        // Torna alla home se il gruppo non esiste più
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

        // Definisce le schermate principali
        final List<Widget> screens = [
          HomeScreen(
            state: widget.state,
            onNavigate: _navigate,
            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
          PantryScreen(
            state: widget.state,

            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
          ShoppingScreen(
            state: widget.state,

            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
          RecipesScreen(
            state: widget.state,

            onCartPressed: () => showNearbySupermarketsModal(context, widget.state),
          ),
        ];

        return PopScope(
            canPop: _currentIndex == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_currentIndex != 0) {
                _navigate(0);
              }
            },
            child: Scaffold(
              body: screens[_currentIndex],

              // Configura la barra di navigazione inferiore
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
                  indicatorColor: AppColors.primaryLight,
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
                    NavigationDestination(
                      icon: ChefHatIcon(color: AppColors.textSecondary, size: 24),
                      selectedIcon: ChefHatIcon(color: AppColors.primary, size: 24),
                      label: 'Ricette',
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

}
