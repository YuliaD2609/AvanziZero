import 'package:flutter/material.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/pantry_screen.dart';
import 'screens/shopping_screen.dart';

void main() {
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
          title: 'FarFromHome',
          debugShowCheckedModeBanner: false,
          
          // Tema globale basato sui token Pastel Sage & Soft Mint
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF5A9E87), // Verde Salvia Intenso
            scaffoldBackgroundColor: const Color(0xFFFBFBF9), // Avorio Soft
            fontFamily: 'Outfit',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5A9E87),
              primary: const Color(0xFF5A9E87),
              secondary: const Color(0xFFFFB088), // Pesca Pastello
              surface: Colors.white,
              onSurface: const Color(0xFF1C3D32), // Verde Foresta Scuro
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          
          home: MainNavigator(state: _appState),
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
      ),
      PantryScreen(
        state: widget.state,
        onHomePressed: () => _navigate(0),
        onCartPressed: () => _showHouseSyncSimple(context),
      ),
      ShoppingScreen(
        state: widget.state,
        onHomePressed: () => _navigate(0),
        onCartPressed: () => _showHouseSyncSimple(context),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      
      // Barra di navigazione inferiore fluida e moderna
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0A1C3D32),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigate,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD1FAE5), // Menta Chiaro per tab attiva
          elevation: 0,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF789088)),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF5A9E87)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.kitchen_outlined, color: Color(0xFF789088)),
              selectedIcon: Icon(Icons.kitchen_rounded, color: Color(0xFF5A9E87)),
              label: 'Dispensa',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: Color(0xFF789088)),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: Color(0xFF5A9E87)),
              label: 'Spesa',
            ),
          ],
        ),
      ),
    );
  }

  // Modale ridotto per sincronizzazione spese richiamabile dall'icona in alto a destra
  void _showHouseSyncSimple(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Bilancio Coinquilini (House Sync)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C3D32)),
            ),
            const SizedBox(height: 12),
            Text(
              "Totale mese: €${widget.state.totalExpenses.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A9E87)),
              child: const Text("Chiudi", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
