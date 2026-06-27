import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';

class HorizontalHeaderMenu extends StatelessWidget {
  final String title;
  final VoidCallback? onCartPressed;
  final Widget? leftAction;
  final List<Widget>? customActions;

  const HorizontalHeaderMenu({
    super.key,
    required this.title,
    this.onCartPressed,
    this.leftAction,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    // Layout menu orizzontale
    return Container(
      height:
          85, // Altezza menu orizzontale
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Titolo sezione centrale perfettamente centrato
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60), // Margine per non sovrapporsi alle icone
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Azioni (Row per distanziarli agli estremi)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Azione sinistra (es. menu laterale) o spazio vuoto
                leftAction != null
                    ? leftAction!
                    : const SizedBox(width: 48),

                // Azioni a destra
                customActions != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: customActions!,
                      )
                    : (onCartPressed != null
                        ? IconButton(
                            icon: Icon(Icons.storefront_rounded,
                                color: AppColors.textPrimary, size: 28),
                            onPressed: onCartPressed,
                            tooltip: 'Supermercati nelle vicinanze',
                          )
                        : const SizedBox(width: 48)),
              ],
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

  // Dialogo nuova categoria
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
                        child: const Text("Ho capito",
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

  // Dialogo elimina categoria
  void _showDeleteCategoryDialog(BuildContext context, String category) {
    if (category == "Tutti") return; // Impedisce eliminazione Tutti

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

    // Layout menu verticale
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
          // Lista categorie scrollabile
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
                        // Testo categoria
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

          // Pulsante aggiungi categoria
          InkWell(
            onTap: () => _showAddCategoryDialog(context),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
