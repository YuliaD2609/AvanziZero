import 'package:flutter/material.dart';
import '../models/app_state.dart';
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
        color: AppColors.primary,
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
                            color: Colors.white, size: 30),
                        onPressed: onHomePressed,
                        tooltip: 'Torna alla Home',
                      )
                    : const SizedBox(width: 48)),

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
              icon: Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 28),
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
  final AppState state;
  final String section;

  const VerticalCategoryMenu({
    super.key,
    required this.state,
    required this.section,
  });

  // Finestra di dialogo per aggiungere una nuova categoria
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController catController = TextEditingController();
    final String title = section == 'pantry' ? "Nuova Categoria Dispensa" : "Nuova Categoria Spesa";
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(title,
            style:
                TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: TextField(
          controller: catController,
          decoration:
              const InputDecoration(hintText: "Nome categoria (es. Dolci)"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              state.addCustomCategory(catController.text, section);
              Navigator.pop(dialogContext);
              if (!state.categoryDeleteHintShown) {
                state.markCategoryDeleteHintShown();
                showDialog(
                  context: context, 
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text("Suggerimento",
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                color: AppColors.primary)),
                      ],
                    ),
                    content: Text(
                      "Tieni premuto su una categoria per eliminarla.",
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          color: AppColors.textPrimary),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Ho capito",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Outfit')),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child:
                const Text("Aggiungi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Finestra di dialogo per eliminare una categoria personalizzata
  void _showDeleteCategoryDialog(BuildContext context, String category) {
    if (category == "Tutti") return; // Non è possibile eliminare "Tutti"

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("Elimina Categoria",
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.error)),
        content:
            Text("Sei sicuro di voler eliminare la categoria '$category'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              state.removeCustomCategory(category, section);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = state.categories;
    final selectedCategory = section == 'pantry' 
        ? state.selectedPantryCategory 
        : state.selectedShoppingCategory;

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
                  onTap: () => state.selectCategory(category, section),
                  onLongPress: () => _showDeleteCategoryDialog(context, category),
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
            onTap: () => _showAddCategoryDialog(context),
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
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Alto contrasto
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
