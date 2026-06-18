import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';
import '../theme/app_colors.dart';

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
                  categories: widget.state.shoppingCategories,
                  selectedCategory: widget.state.selectedShoppingCategory,
                  onCategorySelected: (category) => widget.state.selectCategory(category, 'shopping'),
                  onAddCategoryPressed: () => _showAddCategoryDialog(context),
                ),

                // Colonna destra: Barra di ricerca, Predictive badge, Lista Prodotti e Pulsanti
                Expanded(
                  child: Column(
                    children: [
                      // Barra di Ricerca (search_bar)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  decoration: const InputDecoration(
                                    hintText: "Cerca un prodotto",
                                    hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryVariant,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                      ),

                      // Avviso / Badge Predictive Shopping (Business Model Canvas)
                      if (!widget.state.isPredictiveBannerClosed) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight, // Menta Chiaro
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Predictive Shopping: suggerimenti automatici e previsione scorte",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  widget.state.closePredictiveBannerPermanent();
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Lista della Spesa (ShoppingItemList)
                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return _buildShoppingItemCard(item);
                                },
                              ),
                      ),

                      // Pulsante Spesa fatta
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_checkedItems.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Seleziona almeno un prodotto per completare la spesa!")),
                                );
                                return;
                              }
                              widget.state.markSelectedShoppingDone(_checkedItems.toList());
                              setState(() {
                                _checkedItems.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Spesa Fatta! Prodotti selezionati trasferiti in Dispensa con successo."),
                                  backgroundColor: AppColors.primary,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight, // Menta Chiaro
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              "Spesa fatta",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary, // Verde Foresta Scuro (scurito)
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Pulsante Aggiungi un Elemento (addItemButton)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => _showAddItemDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark, // Accento Verde Scuro/Teal
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              "Aggiungi un elemento",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
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
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Nome del prodotto
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
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
                  child: const Center(child: Text("-", style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${item.quantity}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                  child: const Center(child: Text("+", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Nuova Categoria Spesa", style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(hintText: "Nome categoria"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              widget.state.addCustomCategory(catController.text, 'shopping');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Aggiungi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    bool nameError = false;
    String selectedCat = widget.state.selectedShoppingCategory == "Tutti"
        ? widget.state.shoppingCategories[1]
        : widget.state.selectedShoppingCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Aggiungi Elemento Spesa", style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: widget.state.shoppingCategories
                    .where((c) => c != "Tutti")
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedCat = val!),
                decoration: const InputDecoration(labelText: "Categoria"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
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
              child: const Text("Inserisci", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
