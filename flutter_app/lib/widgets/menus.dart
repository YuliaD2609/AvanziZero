import 'package:flutter/material.dart';

class HorizontalHeaderMenu extends StatelessWidget {
  final String title;
  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;
  final bool showHome;

  const HorizontalHeaderMenu({
    super.key,
    required this.title,
    required this.onHomePressed,
    required this.onCartPressed,
    this.showHome = true,
  });

  @override
  Widget build(BuildContext context) {
    // Implementa il layout di horizontal_menu.xml con stile Pastel Sage
    return Container(
      height: 85, // Altezza proporzionata per il mobile (leggermente ingrandito)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A9E87), Color(0xFF76B59D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A1C3D32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Pulsante Home a sinistra come da layout nativo
            showHome
                ? IconButton(
                    icon: const Icon(Icons.home_rounded, color: Colors.white, size: 30),
                    onPressed: onHomePressed,
                    tooltip: 'Torna alla Home',
                  )
                : const SizedBox(width: 48),
            
            // Titolo della sezione al centro
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Pulsante Supermercati Vicini a destra
            IconButton(
              icon: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
              onPressed: onCartPressed,
              tooltip: 'Supermercati nelle vicinanze',
            ),
          ],
        ),
      ),
    );
  }
}

class VerticalCategoryMenu extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final VoidCallback onAddCategoryPressed;

  const VerticalCategoryMenu({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Implementa vertical_menu.xml: colonna laterale sinistra con la lista delle categorie
    return Container(
      width: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: const Color(0xFFEAECE8), width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x051C3D32),
            blurRadius: 4,
            offset: Offset(2, 0),
          )
        ],
      ),
      child: Column(
        children: [
          // Lista scrollabile delle categorie
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;

                return InkWell(
                  onTap: () => onCategorySelected(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5A9E87) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF5A9E87) : const Color(0xFFEAECE8),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Solo testo per la categoria come richiesto
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF1C3D32),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Pulsante (+) in fondo per aggiungere una nuova categoria (addCategory)
          InkWell(
            onTap: onAddCategoryPressed,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB088), // Accento Pesca Pastello
                borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
              ),
              child: const Center(
                child: Text(
                  "+",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C3D32), // Alto contrasto
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Tutti":
        return Icons.grid_view_rounded;
      case "Frutta & Verdura":
        return Icons.apple_rounded;
      case "Latticini":
        return Icons.egg_rounded;
      case "Carne & Pesce":
        return Icons.set_meal_rounded;
      case "Secco & Pasta":
        return Icons.breakfast_dining_rounded;
      case "Bevande":
        return Icons.local_drink_rounded;
      case "Igiene Casa":
        return Icons.cleaning_services_rounded;
      case "Vestiti":
        return Icons.checkroom_rounded;
      case "Libri & Studio":
        return Icons.menu_book_rounded;
      case "Cavi & Tech":
        return Icons.cable_rounded;
      case "Beauty & Igiene":
        return Icons.face_retouching_natural_rounded;
      default:
        return Icons.folder_special_rounded;
    }
  }
}
