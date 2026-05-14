import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';

class SuitcaseScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;

  const SuitcaseScreen({
    super.key,
    required this.state,
    required this.onHomePressed,
    required this.onCartPressed,
  });

  @override
  State<SuitcaseScreen> createState() => _SuitcaseScreenState();
}

class _SuitcaseScreenState extends State<SuitcaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Filtra la valigia per categoria attiva e query
    final filteredItems = widget.state.allItems.where((item) {
      if (!item.isSuitcase) return false;
      final matchesCategory = widget.state.selectedSuitcaseCategory == "Tutti" ||
          item.category == widget.state.selectedSuitcaseCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9), // Avorio soft
      body: Column(
        children: [
          // Menu Orizzontale Superiore
          HorizontalHeaderMenu(
            title: "Valigia",
            onHomePressed: widget.onHomePressed,
            onCartPressed: widget.onCartPressed,
          ),

          // Corpo Centrale
          Expanded(
            child: Row(
              children: [
                // Menu Verticale Sinistro
                VerticalCategoryMenu(
                  categories: widget.state.suitcaseCategories,
                  selectedCategory: widget.state.selectedSuitcaseCategory,
                  onCategorySelected: (category) => widget.state.selectCategory(category, 'suitcase'),
                  onAddCategoryPressed: () => _showAddCategoryDialog(context),
                ),

                // Colonna Destra
                Expanded(
                  child: Column(
                    children: [
                      // Barra di Ricerca
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

                      // Lista Elementi Valigia
                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
                                child: Text(
                                  "Valigia vuota in questa categoria.",
                                  style: TextStyle(color: Color(0xFF789088), fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return _buildSuitcaseItemCard(item);
                                },
                              ),
                      ),

                      // Pulsante Aggiungi un Elemento (addItemButton)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ElevatedButton(
                            onPressed: () => _showAddItemDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB088), // Accento Pesca Pastello
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 2,
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

  Widget _buildSuitcaseItemCard(ItemModel item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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

          // Controlli Quantità
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
        title: const Text("Nuova Categoria Valigia", style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF1C3D32))),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(hintText: "Nome categoria (es. Scarpe)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              widget.state.addCustomCategory(catController.text, 'suitcase');
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
    String selectedCat = widget.state.selectedSuitcaseCategory == "Tutti"
        ? widget.state.suitcaseCategories[1]
        : widget.state.selectedSuitcaseCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Aggiungi Elemento Valigia", style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF1C3D32))),
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
                items: widget.state.suitcaseCategories
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
                    isSuitcase: true,
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
