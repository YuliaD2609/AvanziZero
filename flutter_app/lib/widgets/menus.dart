import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HorizontalHeaderMenu extends StatelessWidget {
  final String title;
  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;
  final bool showHome;
  final Widget? leftAction;

  const HorizontalHeaderMenu({
    super.key,
    required this.title,
    required this.onHomePressed,
    required this.onCartPressed,
    this.showHome = true,
    this.leftAction,
  });

  @override
  Widget build(BuildContext context) {
    // Implementa il layout di horizontal_menu.xml con stile Pastel Sage
    return Container(
      height:
          85, // Altezza proporzionata per il mobile (leggermente ingrandito)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Pulsante Home o leftAction a sinistra come da layout nativo
            leftAction != null
                ? leftAction!
                : (showHome
                    ? IconButton(
                        icon: Icon(Icons.home_rounded,
                            color: AppColors.surfaceLight, size: 30),
                        onPressed: onHomePressed,
                        tooltip: 'Torna alla Home',
                      )
                    : const SizedBox(width: 48)),

            // Titolo della sezione al centro
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.surfaceLight,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Pulsante Supermercati Vicini a destra
            IconButton(
              icon: Icon(Icons.storefront_rounded,
                  color: AppColors.surfaceLight, size: 28),
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
  final Function(String)? onCategoryLongPressed;
  final VoidCallback onAddCategoryPressed;

  const VerticalCategoryMenu({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.onCategoryLongPressed,
    required this.onAddCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Implementa vertical_menu.xml: colonna laterale sinistra con la lista delle categorie
    return Container(
      width: 85,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(2, 0),
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
                  onLongPress: onCategoryLongPressed != null
                      ? () => onCategoryLongPressed!(category)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
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
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
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
              decoration: BoxDecoration(
                color: AppColors.primaryDark, // Accento Verde Scuro/Teal
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  "+",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surfaceLight, // Alto contrasto
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
