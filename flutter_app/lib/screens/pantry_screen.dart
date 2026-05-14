import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';

class PantryScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;

  const PantryScreen({
    super.key,
    required this.state,
    required this.onHomePressed,
    required this.onCartPressed,
  });

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Filtra i prodotti dispensa in base alla categoria attiva e alla barra di ricerca
    final filteredItems = widget.state.allItems.where((item) {
      if (!item.isPantry) return false;
      final matchesCategory = widget.state.selectedPantryCategory == "Tutti" ||
          item.category == widget.state.selectedPantryCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9), // Avorio soft
      body: Column(
        children: [
          // Menu Orizzontale Superiore come da layout nativo
          HorizontalHeaderMenu(
            title: "Dispensa",
            onHomePressed: widget.onHomePressed,
            onCartPressed: widget.onCartPressed,
          ),

          // Corpo Centrale: Menu Verticale Categorie a sinistra, Barra Ricerca e Prodotti a destra
          Expanded(
            child: Row(
              children: [
                // Menu Verticale a sinistra (lasciata intatta la divisione in categorie)
                VerticalCategoryMenu(
                  categories: widget.state.pantryCategories,
                  selectedCategory: widget.state.selectedPantryCategory,
                  onCategorySelected: (category) => widget.state.selectCategory(category, 'pantry'),
                  onAddCategoryPressed: () => _showAddCategoryDialog(context),
                ),

                // Sezione Destra: Barra di ricerca e Lista
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

                      // Contenitore Frammento Prodotti (item_fragment_container)
                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nessun prodotto presente in questa categoria.",
                                  style: TextStyle(color: Color(0xFF789088), fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return _buildPantryItemCard(item);
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

  // Costruisce la card prodotto seguendo pantry_item_layout.xml
  Widget _buildPantryItemCard(ItemModel item) {
    // Colore del bordo in base all'urgenza "Zero Spreco"
    Color urgencyColor = const Color(0xFFEAECE8);
    if (item.urgencyLevel == 2) urgencyColor = const Color(0xFFEF4444); // Rosso
    if (item.urgencyLevel == 1) urgencyColor = const Color(0xFFF59E0B); // Giallo

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: urgencyColor, width: item.urgencyLevel > 0 ? 1.5 : 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081C3D32),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pallino segnaposto a sinistra
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.urgencyLevel == 2
                      ? const Color(0xFFEF4444)
                      : (item.urgencyLevel == 1 ? const Color(0xFFF59E0B) : const Color(0xFF5A9E87)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Nome Prodotto (itemName)
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
            ],
          ),
          const SizedBox(height: 8),

          // Sezione Scadenza e Quantità
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Scadenza testuale nativa (TextExpire + itemExpire)
              Expanded(
                child: Text(
                  item.expireDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: item.urgencyLevel == 2 ? const Color(0xFFEF4444) : const Color(0xFF789088),
                    fontWeight: item.urgencyLevel > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),

              // Controlli Quantità (+ / -)
              Row(
                children: [
                  const Text(
                    "Quantità:",
                    style: TextStyle(fontSize: 13, color: Color(0xFF789088)),
                  ),
                  const SizedBox(width: 6),
                  
                  // Pulsante Decremento (-)
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
                      child: const Center(
                        child: Text("-", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C3D32))),
                      ),
                    ),
                  ),
                  
                  // Quantità Attuale (itemQuantity)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "${item.quantity}",
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C3D32),
                      ),
                    ),
                  ),

                  // Pulsante Incremento (+)
                  InkWell(
                    onTap: () => widget.state.updateQuantity(item.id, 1),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A9E87),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text("+", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Finestra di dialogo per aggiungere una nuova categoria
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Nuova Categoria Dispensa", style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF1C3D32))),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(hintText: "Nome categoria (es. Dolci)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              widget.state.addCustomCategory(catController.text, 'pantry');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A9E87)),
            child: const Text("Aggiungi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Finestra di dialogo per aggiungere manualmente un prodotto
  void _showAddItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController expireController = TextEditingController(text: "Scadenza: tra 7 giorni");
    String selectedCat = widget.state.selectedPantryCategory == "Tutti"
        ? widget.state.pantryCategories[1]
        : widget.state.selectedPantryCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Aggiungi Elemento Dispensa", style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF1C3D32))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome Elemento"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: expireController,
                decoration: const InputDecoration(labelText: "Data Scadenza testuale"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: widget.state.pantryCategories
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
                    expireDate: expireController.text,
                    quantity: 1,
                    category: selectedCat,
                    isPantry: true,
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
