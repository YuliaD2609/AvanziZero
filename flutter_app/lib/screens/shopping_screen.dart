import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';
import '../theme/app_colors.dart';
import '../services/ai_scanner_service.dart';

class ShoppingScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;

  const ShoppingScreen({
    super.key,
    required this.state,
    required this.onHomePressed,
    required this.onCartPressed,
  });

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final Set<String> _checkedItems = {};

  @override
  Widget build(BuildContext context) {
    // Filtra la lista della spesa per categoria attiva e query di ricerca
    final filteredItems = widget.state.allItems.where((item) {
      if (!item.isShopping) return false;
      final matchesCategory = widget.state.selectedShoppingCategory == "Tutti" ||
          item.category == widget.state.selectedShoppingCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background, // Avorio soft
      body: Column(
        children: [
          // Menu Orizzontale Superiore
          HorizontalHeaderMenu(
            title: "Lista della spesa",
            onHomePressed: widget.onHomePressed,
            onCartPressed: widget.onCartPressed,
            showHome: false,
          ),

          // Corpo della schermata: Categorie a sinistra, Ricerca/Lista a destra
          Expanded(
            child: Row(
              children: [
                // Menu Verticale sinistro (Categorie List lasciate intatte)
                VerticalCategoryMenu(
                  categories: widget.state.categories,
                  selectedCategory: widget.state.selectedShoppingCategory,
                  onCategorySelected: (category) => widget.state.selectCategory(category, 'shopping'),
                  onCategoryLongPressed: (category) => _showDeleteCategoryDialog(context, category, 'shopping'),
                  onAddCategoryPressed: () => _showAddCategoryDialog(context),
                ),

                // Colonna destra: Barra di ricerca, Predictive badge, Lista Prodotti e Pulsanti
                Expanded(
                  child: Column(
                    children: [
                      // Barra di Ricerca (search_bar)
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  decoration: InputDecoration(
                                    hintText: "Cerca un prodotto",
                                    hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryVariant,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(Icons.search_rounded, color: AppColors.surfaceLight, size: 22),
                            ),
                          ],
                        ),
                      ),



                      // Area principale: Lista della spesa e Pulsanti sovrapposti
                      Expanded(
                        child: Stack(
                          children: [
                            // 1. Lista della spesa scrollabile dietro i pulsanti
                            Positioned.fill(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          "Lista della spesa vuota per questa categoria.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 130), // Padding extra per scrollare oltre i pulsanti
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return _buildShoppingItemCard(item);
                                      },
                                    ),
                            ),
                            
                            // 2. Pulsanti flottanti in basso a destra
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Pulsante Spesa fatta
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_checkedItems.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Seleziona almeno un prodotto per completare la spesa!")),
                                        );
                                        return;
                                      }
                                      widget.state.markSelectedShoppingDone(_checkedItems.toList());
                                      setState(() {
                                        _checkedItems.clear();
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Spesa Fatta! Prodotti selezionati trasferiti in Dispensa con successo."),
                                          backgroundColor: AppColors.primary,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryLight, // Menta Chiaro
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Text(
                                      "Spesa fatta",
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary, // Verde Foresta Scuro
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: 12),
                                  
                                  // Pulsanti flottanti in basso a destra
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Pulsante Predictive Shopping
                                      FloatingActionButton(
                                        heroTag: "predictive_btn",
                                        onPressed: () => _showPredictiveShoppingModal(context),
                                        backgroundColor: AppColors.primaryLight,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                                      ),
                                      SizedBox(width: 12),
                                      // Pulsante Aggiungi un Elemento
                                      ElevatedButton(
                                        onPressed: () => _showAddItemDialog(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryDark, // Accento Verde Scuro/Teal
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: Text(
                                          "Aggiungi un elemento",
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.surfaceLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce la riga prodotto lista spesa
  Widget _buildShoppingItemCard(ItemModel item) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox di selezione
          InkWell(
            onTap: () {
              setState(() {
                if (_checkedItems.contains(item.id)) {
                  _checkedItems.remove(item.id);
                } else {
                  _checkedItems.add(item.id);
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _checkedItems.contains(item.id) ? AppColors.primary : Colors.transparent,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _checkedItems.contains(item.id)
                  ? Icon(Icons.check_rounded, color: AppColors.surfaceLight, size: 18)
                  : null,
            ),
          ),
          SizedBox(width: 12),

          // Nome del prodotto
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Quantità e Controlli (+ / -) come da layout
          Row(
            children: [
              InkWell(
                onTap: () => widget.state.updateQuantity(item.id, -1),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(child: Text("-", style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${item.quantity}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              InkWell(
                onTap: () => widget.state.updateQuantity(item.id, 1),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text("+", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPredictiveShoppingModal(BuildContext context) {
    bool isAILoading = true;
    List<ItemModel> scarcityItems = [];
    List<ItemModel> expiringItems = [];
    bool hasFetched = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          // Lancia la chiamata AI solo al primo render
          if (!hasFetched) {
            hasFetched = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final history = await widget.state.firebaseService?.getConsumptionHistory() ?? [];
                final pantryItems = widget.state.allItems.where((i) => i.isPantry).toList();
                final shoppingItems = widget.state.allItems.where((i) => i.isShopping).toList();
                final groupSize = widget.state.groupMembers.isNotEmpty ? widget.state.groupMembers.length : 1;
                
                final result = await AIScannerService.getPredictiveSuggestions(
                  pantryItems,
                  shoppingItems,
                  history,
                  groupSize,
                );
                
                if (mounted) {
                  setStateModal(() {
                    scarcityItems = result["scarcity"] ?? [];
                    expiringItems = result["expiring"] ?? [];
                    isAILoading = false;
                  });
                }
              } catch (e) {
                if (mounted) {
                  setStateModal(() {
                    isAILoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore IA: $e")));
                }
              }
            });
          }

          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Predictive Shopping",
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  isAILoading ? "L'IA sta analizzando lo storico dei consumi..." : "I suggerimenti intelligenti basati sulle tue abitudini.",
                  style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 14),
                ),
                SizedBox(height: 24),
                if (isAILoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text("Elaborazione IA in corso...", style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  )
                else if (scarcityItems.isEmpty && expiringItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text("Nessun suggerimento al momento! Non ci sono elementi in scadenza o che stanno per finire.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else ...[
                  if (scarcityItems.isNotEmpty) ...[
                    Text("Scarsità prodotti", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.primary)),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: scarcityItems.map((item) => _buildSuggestionChip(item)).toList(),
                    ),
                    SizedBox(height: 24),
                  ],
                  if (expiringItems.isNotEmpty) ...[
                    Text("Vicino alla scadenza", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.error)),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: expiringItems.map((item) => _buildSuggestionChip(item)).toList(),
                    ),
                  ],
                ],
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionChip(ItemModel item) {
    return ActionChip(
      backgroundColor: AppColors.background,
      side: BorderSide(color: AppColors.primaryLight),
      label: Text("+ ${item.name}", style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      onPressed: () {
        final newItemId = DateTime.now().millisecondsSinceEpoch.toString();
        final newItem = ItemModel(
          id: newItemId,
          name: item.name,
          expireDate: "Data: N/A", // Default per la spesa
          quantity: 1,
          category: item.category,
          isShopping: true,
          isPantry: false,
        );
        widget.state.addItem(newItem);
        Navigator.pop(context); // Chiude il modal
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${item.name} aggiunto alla spesa!"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ));
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController catController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("Nuova Categoria Spesa", style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: TextField(
          controller: catController,
          decoration: InputDecoration(hintText: "Nome categoria"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              widget.state.addCustomCategory(catController.text, 'shopping');
              Navigator.pop(dialogContext);
              if (!widget.state.categoryDeleteHintShown) {
                widget.state.markCategoryDeleteHintShown();
                showDialog(
                  context: context, // Usiamo il context esterno (sicuro)
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text("Suggerimento", style: TextStyle(fontFamily: 'Outfit', color: AppColors.primary)),
                      ],
                    ),
                    content: Text(
                      "Tieni premuto su una categoria per eliminarla.",
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.textPrimary),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Ho capito", style: TextStyle(color: AppColors.surfaceLight, fontFamily: 'Outfit')),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text("Aggiungi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String category, String section) {
    if (category == "Tutti") return; // Non è possibile eliminare "Tutti"

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("Elimina Categoria", style: TextStyle(fontFamily: 'Outfit', color: AppColors.error)),
        content: Text("Sei sicuro di voler eliminare la categoria '$category'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              widget.state.removeCustomCategory(category, section);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    bool nameError = false;
    String selectedCat = widget.state.selectedShoppingCategory == "Tutti"
        ? widget.state.categories[1]
        : widget.state.selectedShoppingCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          title: Text("Aggiungi Elemento Spesa", style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nome Elemento",
                  errorText: nameError ? "Inserisci il nome dell'elemento" : null,
                ),
                onChanged: (val) {
                  if (nameError && val.trim().isNotEmpty) {
                    setDialogState(() => nameError = false);
                  }
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: widget.state.categories
                    .where((c) => c != "Tutti")
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedCat = val!),
                decoration: InputDecoration(labelText: "Categoria"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  widget.state.addItem(ItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    expireDate: "-",
                    quantity: 1,
                    category: selectedCat,
                    isShopping: true,
                  ));
                  Navigator.pop(context);
                } else {
                  setDialogState(() => nameError = true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text("Inserisci", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
