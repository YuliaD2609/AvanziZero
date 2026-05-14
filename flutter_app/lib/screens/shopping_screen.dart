import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';

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
      backgroundColor: const Color(0xFFFBFBF9), // Avorio soft
      body: Column(
        children: [
          // Menu Orizzontale Superiore
          HorizontalHeaderMenu(
            title: "Lista della spesa",
            onHomePressed: widget.onHomePressed,
            onCartPressed: widget.onCartPressed,
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
                  child: Stack(
                    children: [
                      Column(
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
                                      border: Border.all(color: const Color(0xFFEAECE8)),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) => setState(() => _searchQuery = val),
                                      decoration: const InputDecoration(
                                        hintText: "Cerca un prodotto",
                                        hintStyle: TextStyle(color: Color(0xFFA9A69E), fontSize: 14),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      style: const TextStyle(color: Color(0xFF1C3D32), fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5A9E87),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                                ),
                              ],
                            ),
                          ),

                          // Avviso / Badge Predictive Shopping (Business Model Canvas)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5), // Menta Chiaro
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: Color(0xFF5A9E87), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Predictive Shopping: suggerimenti automatici e previsione scorte",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C3D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Lista della Spesa (ShoppingItemList)
                          Expanded(
                            child: filteredItems.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Lista della spesa vuota per questa categoria.",
                                      style: TextStyle(color: Color(0xFF789088), fontSize: 14),
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

                          // Pulsante Aggiungi un Elemento (addItemButton)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showAddItemDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB088), // Accento Pesca Pastello
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  "Aggiungi un elemento",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C3D32),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Margine inferiore per fare spazio al pulsante sovrapposto "Spesa fatta"
                          const SizedBox(height: 70),
                        ],
                      ),

                      // Pulsante sovrapposto in basso a destra "Spesa fatta" (shoppingDone)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.state.markShoppingDone();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Spesa Fatta! Prodotti trasferiti in Dispensa con successo."),
                                backgroundColor: Color(0xFF5A9E87),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A9E87), // Verde Salvia Intenso
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text(
                            "Spesa fatta",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        border: Border.all(color: const Color(0xFFEAECE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x051C3D32),
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
              // Rimuovi o sposta istantaneamente
              setState(() {
                item.isShopping = false;
                item.isPantry = true;
                item.expireDate = "Scadenza: Fresco";
              });
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF5A9E87), width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
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
                color: Color(0xFF1C3D32),
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
                    color: const Color(0xFFFBFBF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAECE8)),
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
                    color: const Color(0xFF5A9E87),
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
        title: const Text("Nuova Categoria Spesa", style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF1C3D32))),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A9E87)),
            child: const Text("Aggiungi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String selectedCat = widget.state.selectedShoppingCategory == "Tutti"
        ? widget.state.shoppingCategories[1]
        : widget.state.selectedShoppingCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Aggiungi Elemento Spesa", style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF1C3D32))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome Elemento"),
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
                if (nameController.text.isNotEmpty) {
                  widget.state.addItem(ItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    expireDate: "-",
                    quantity: 1,
                    category: selectedCat,
                    isShopping: true,
                  ));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A9E87)),
              child: const Text("Inserisci", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
