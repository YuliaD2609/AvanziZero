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
            snackBarTheme: SnackBarThemeData(
              backgroundColor: AppColors.primary,
              contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              behavior: SnackBarBehavior.floating,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          // Configura il routing dinamico
          home: SplashScreen(
            skip: _appState.skipStartupAnimation,
            nextScreen: _appState.currentUserAuth == null
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
          ),
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

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  final bool skip;
  const SplashScreen({super.key, required this.nextScreen, required this.skip});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  int _step = 0; // 0: inizio, 1: matita su Pane, 2: Pane check, 3: matita su Uova, 4: Uova check, 5: matita su AvanziZero, 6: AvanziZero check + bagliore, 7: fine
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.skip) {
      _animationCompleted = true;
    } else {
      _startAnimationSequence();
    }
  }

  void _startAnimationSequence() async {
    // Sequenza temporizzata più rapida e scattante (totale ~2.0 secondi)
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() { _step = 1; }); // Movimento verso Pane
    
    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() { _step = 2; }); // Check Pane

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() { _step = 3; }); // Movimento verso Uova

    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() { _step = 4; }); // Check Uova

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() { _step = 5; }); // Movimento verso AvanziZero

    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() { _step = 6; }); // Check AvanziZero + Illuminazione

    await Future.delayed(const Duration(milliseconds: 500)); // Pausa per far ammirare l'illuminazione
    if (!mounted) return;
    setState(() { _animationCompleted = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCompleted) {
      return widget.nextScreen;
    }

    // Altezze calcolate per la matita, molto più distanziate
    double pencilTop = 25.0;
    if (_step >= 5) {
      pencilTop = 285.0; // Posizione AvanziZero
    } else if (_step >= 3) {
      pencilTop = 155.0;  // Posizione Uova
    } else if (_step >= 1) {
      pencilTop = 25.0;  // Posizione Pane
    }

    double pencilRight = 15.0;
    if (_step == 2 || _step == 4 || _step == 6) {
      pencilRight = 35.0; // Simula il tocco sulla casella
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: 330,
          height: 380,
          child: Stack(
            children: [
              // Lista delle 3 caselle molto più ampie e distanziate
              Positioned(
                left: 10,
                top: 20,
                right: 55,
                child: _buildCheckItem(
                  title: "Pane",
                  isChecked: _step >= 2,
                  isGlowing: false,
                  iconData: Icons.bakery_dining,
                ),
              ),
              Positioned(
                left: 10,
                top: 150,
                right: 55,
                child: _buildCheckItem(
                  title: "Uova",
                  isChecked: _step >= 4,
                  isGlowing: false,
                  iconData: Icons.egg_outlined,
                ),
              ),
              Positioned(
                left: 10,
                top: 280,
                right: 55,
                child: _buildCheckItem(
                  title: "AvanziZero",
                  isChecked: _step >= 6,
                  isGlowing: _step >= 6,
                  iconData: Icons.eco,
                ),
              ),

              // Matita animata
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                top: pencilTop,
                right: pencilRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _step == 0 ? 0.0 : (_step >= 6 ? 0.0 : 1.0), // Scompare elegantemente al termine
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Icon(
                      Icons.edit,
                      size: 38,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    required bool isChecked,
    required bool isGlowing,
    required IconData iconData,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: isGlowing ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGlowing ? AppColors.primary : AppColors.border,
          width: isGlowing ? 2.0 : 1.0,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: isChecked
                ? Icon(
                    Icons.check_box,
                    key: const ValueKey('checked'),
                    color: isGlowing ? AppColors.primary : Colors.green,
                    size: 28,
                  )
                : Icon(
                    Icons.check_box_outline_blank,
                    key: const ValueKey('unchecked'),
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 28,
                  ),
          ),
          const SizedBox(width: 18),
          Icon(iconData, color: isGlowing ? AppColors.primary : AppColors.textSecondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: isGlowing ? FontWeight.bold : FontWeight.w600,
                color: isGlowing ? AppColors.primary : AppColors.textPrimary,
                shadows: isGlowing
                    ? [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 12,
                        )
                      ]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
