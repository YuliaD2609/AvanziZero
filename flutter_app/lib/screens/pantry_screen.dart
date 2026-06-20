import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';
import '../widgets/ocr_scanner_modal.dart';
import '../theme/app_colors.dart';

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
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Ordina i prodotti in ordine alfabetico (case insensitive)
    filteredItems
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      backgroundColor: AppColors.background, // Avorio soft
      body: Column(
        children: [
          // Menu Orizzontale Superiore come da layout nativo
          HorizontalHeaderMenu(
            title: "Dispensa",
            onHomePressed: widget.onHomePressed,
            onCartPressed: widget.onCartPressed,
            showHome: false,
          ),

          // Corpo Centrale: Menu Verticale Categorie a sinistra, Barra Ricerca e Prodotti a destra
          Expanded(
            child: Row(
              children: [
                // Menu Verticale a sinistra (lasciata intatta la divisione in categorie)
                VerticalCategoryMenu(
                  categories: widget.state.categories,
                  selectedCategory: widget.state.selectedPantryCategory,
                  onCategorySelected: (category) =>
                      widget.state.selectCategory(category, 'pantry'),
                  onCategoryLongPressed: (category) =>
                      _showDeleteCategoryDialog(context, category, 'pantry'),
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
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(22),
                                  border:
                                      Border.all(color: AppColors.borderLight),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) =>
                                      setState(() => _searchQuery = val),
                                  decoration: InputDecoration(
                                    hintText: "Cerca un prodotto",
                                    hintStyle: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14),
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
                              child: Icon(Icons.search_rounded,
                                  color: AppColors.surfaceLight, size: 22),
                            ),
                          ],
                        ),
                      ),

                      // Area principale: Lista dispensa e Pulsanti sovrapposti
                      Expanded(
                        child: Stack(
                          children: [
                            // 1. Lista dispensa scrollabile dietro i pulsanti
                            Positioned.fill(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24),
                                        child: Text(
                                          "Dispensa vuota per questa categoria.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          bottom:
                                              80), // Padding extra per scrollare oltre i pulsanti
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return _buildPantryItemCard(item);
                                      },
                                    ),
                            ),

                            // 2. Pulsanti flottanti in basso a destra
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FloatingActionButton(
                                    heroTag: 'scanner_fab',
                                    onPressed: () =>
                                        _openScannerAndReview(context),
                                    backgroundColor: AppColors.primaryLight,
                                    elevation: 2,
                                    child: Icon(Icons.document_scanner_rounded,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _showAddItemDialog(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors
                                          .primaryDark, // Accento Verde Scuro/Teal
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
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

  // Costruisce la card prodotto seguendo pantry_item_layout.xml
  Widget _buildPantryItemCard(ItemModel item) {
    // Colore del bordo in base all'urgenza "Zero Spreco"
    Color urgencyColor = AppColors.border;
    if (item.urgencyLevel == 2) urgencyColor = AppColors.error; // Rosso
    if (item.urgencyLevel == 1) urgencyColor = AppColors.warning; // Giallo

    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
            onTap: () => _showEditItemDialog(context, item),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: urgencyColor,
                    width: item.urgencyLevel > 0 ? 1.5 : 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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
                              ? AppColors.error
                              : (item.urgencyLevel == 1
                                  ? AppColors.warning
                                  : AppColors.primary),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nome Prodotto (itemName)
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
                      if (item.ownerId != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.state.getMemberColor(item.ownerId!),
                          ),
                        ),
                      ],
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
                          item.formattedDateForUI,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.urgencyLevel == 2
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: item.urgencyLevel > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      // Controlli Quantità (+ / -)
                      Row(
                        children: [
                          Text(
                            "Quantità:",
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),

                          // Pulsante Decremento (-)
                          InkWell(
                            onTap: () {
                              if (item.quantity == 1) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.surfaceLight,
                                    title: Text("Prodotto terminato",
                                        style: TextStyle(
                                            fontFamily: 'Outfit',
                                            color: AppColors.textPrimary)),
                                    content: Text(
                                        "Vuoi aggiungere '${item.name}' alla lista della spesa?",
                                        style: TextStyle(
                                            color: AppColors.textSecondary)),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          widget.state
                                              .updateQuantity(item.id, -1);
                                        },
                                        child: const Text("No, rimuovi"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          widget.state.moveToShoppingList(item);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "${item.name} aggiunto alla spesa!"),
                                              backgroundColor:
                                                  AppColors.primary,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary),
                                        child: const Text("Sì, aggiungi",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                widget.state.updateQuantity(item.id, -1);
                              }
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Text("-",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                              ),
                            ),
                          ),

                          // Quantità Attuale (itemQuantity)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${item.quantity}",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // Pulsante Incremento (+)
                          InkWell(
                            onTap: () =>
                                widget.state.updateQuantity(item.id, 1),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text("+",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }

  // Finestra di dialogo per aggiungere una nuova categoria
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController catController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("Nuova Categoria Dispensa",
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
              widget.state.addCustomCategory(catController.text, 'pantry');
              Navigator.pop(dialogContext);
              if (!widget.state.categoryDeleteHintShown) {
                widget.state.markCategoryDeleteHintShown();
                showDialog(
                  context: context, // Usiamo il context esterno (sicuro)
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
                                color: AppColors.surfaceLight,
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
  void _showDeleteCategoryDialog(
      BuildContext context, String category, String section) {
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
              widget.state.removeCustomCategory(category, section);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Finestra di dialogo per aggiungere manualmente un prodotto
  void _showAddItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    bool nameError = false;
    DateTime? selectedDate;
    String selectedCat = widget.state.selectedPantryCategory == "Tutti"
        ? widget.state.categories[1]
        : widget.state.selectedPantryCategory;
    String? selectedOwnerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          title: Text("Aggiungi Elemento Dispensa",
              style: TextStyle(
                  fontFamily: 'Outfit', color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nome Elemento",
                  errorText:
                      nameError ? "Inserisci il nome dell'elemento" : null,
                ),
                onChanged: (val) {
                  if (nameError && val.trim().isNotEmpty) {
                    setDialogState(() => nameError = false);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: selectedDate == null
                      ? ""
                      : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
                ),
                decoration: InputDecoration(
                  labelText: "Data Scadenza (Opzionale)",
                  hintText: "Scegli dal calendario",
                  suffixIcon: selectedDate != null
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            setDialogState(() {
                              selectedDate = null;
                            });
                          },
                        )
                      : Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365 * 10)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: widget.state.isDarkMode
                              ? ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.black,
                                  onSurface: AppColors.textPrimary,
                                  surface: AppColors.background,
                                )
                              : ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  onSurface: AppColors.textPrimary,
                                  surface: AppColors.background,
                                ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCat,
                items: widget.state.categories
                    .where((c) => c != "Tutti")
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedCat = val!),
                decoration: const InputDecoration(labelText: "Categoria"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: selectedOwnerId,
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text("Tutti")),
                  ...widget.state.groupMembers
                      .map((member) => DropdownMenuItem<String?>(
                            value: member.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.state
                                          .getMemberColor(member.id)),
                                ),
                                Text(member.name),
                              ],
                            ),
                          ))
                ],
                onChanged: (val) => setDialogState(() => selectedOwnerId = val),
                decoration: const InputDecoration(labelText: "Proprietà di"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final expireStr = selectedDate == null
                      ? "-"
                      : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";
                  widget.state.addItem(ItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    expireDate: expireStr,
                    quantity: 1,
                    category: selectedCat,
                    isPantry: true,
                    ownerId: selectedOwnerId,
                  ));
                  Navigator.pop(context);
                } else {
                  setDialogState(() => nameError = true);
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Inserisci",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ItemModel item) {
    final TextEditingController nameController =
        TextEditingController(text: item.name);
    final TextEditingController quantityController =
        TextEditingController(text: item.quantity.toString());
    bool nameError = false;

    DateTime? selectedDate = item.parsedExpireDate;

    String selectedCat = widget.state.categories.contains(item.category)
        ? item.category
        : (widget.state.categories.length > 1
            ? widget.state.categories[1]
            : "Altro");
    String? selectedOwnerId = item.ownerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          title: Text("Modifica Prodotto",
              style: TextStyle(
                  fontFamily: 'Outfit', color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nome Elemento",
                    errorText:
                        nameError ? "Inserisci il nome dell'elemento" : null,
                  ),
                  onChanged: (val) {
                    if (nameError && val.trim().isNotEmpty) {
                      setDialogState(() => nameError = false);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  items: widget.state.categories
                      .where((c) => c != "Tutti")
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedCat = val!),
                  decoration: const InputDecoration(labelText: "Categoria"),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDate == null
                        ? "Data: N/A"
                        : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
                  ),
                  decoration: InputDecoration(
                    labelText: "Data Scadenza",
                    hintText: "Scegli dal calendario",
                    suffixIcon: selectedDate != null
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              setDialogState(() {
                                selectedDate = null;
                              });
                            },
                          )
                        : Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 10)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primary,
                              onPrimary: Colors.white,
                              onSurface: AppColors.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantità"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: selectedOwnerId,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text("Tutti")),
                    ...widget.state.groupMembers
                        .map((member) => DropdownMenuItem<String?>(
                              value: member.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.state
                                            .getMemberColor(member.id)),
                                  ),
                                  Text(member.name),
                                ],
                              ),
                            ))
                  ],
                  onChanged: (val) =>
                      setDialogState(() => selectedOwnerId = val),
                  decoration: const InputDecoration(labelText: "Proprietà di"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  int q =
                      int.tryParse(quantityController.text) ?? item.quantity;
                  if (q < 1) q = 1;

                  item.name = nameController.text.trim();
                  item.category = selectedCat;
                  item.quantity = q;
                  item.ownerId = selectedOwnerId;
                  item.expireDate = selectedDate == null
                      ? "Data: N/A"
                      : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";

                  widget.state.updateItem(item);
                  Navigator.pop(context);
                } else {
                  setDialogState(() => nameError = true);
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Salva", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openScannerAndReview(BuildContext context) async {
    // Apriamo la modale di scansione IA che ritornerà la lista dei prodotti
    final List<ItemModel>? scannedItems =
        await showModalBottomSheet<List<ItemModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OcrScannerModal(state: widget.state),
    );

    if (scannedItems != null && scannedItems.isNotEmpty && context.mounted) {
      // Mostriamo il popup per la modifica prima dell'inserimento
      _showScannedItemsReviewDialog(context, scannedItems);
    }
  }

  void _showScannedItemsReviewDialog(
      BuildContext context, List<ItemModel> items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text("Rivedi Prodotti",
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          // Uso ObjectKey per forzare il refresh corretto quando elimino un elemento!
                          return Card(
                            key: ObjectKey(item),
                            color: AppColors.surfaceLight,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side:
                                  BorderSide(color: AppColors.border, width: 1),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Riga 1: Nome prodotto e Pulsante Cestino
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary),
                                          decoration: InputDecoration(
                                            labelText: "Nome Prodotto",
                                            filled: true,
                                            fillColor: AppColors.background,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                          ),
                                          onChanged: (val) => item.name = val,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline_rounded,
                                            color: AppColors.error),
                                        onPressed: () {
                                          setDialogState(() {
                                            items.removeAt(index);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Riga 2: Quantità, Scadenza
                                  Row(
                                    children: [
                                      // Quantità
                                      SizedBox(
                                        width: 60,
                                        child: TextFormField(
                                          initialValue:
                                              item.quantity.toString(),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            labelText: "Qt.",
                                            filled: true,
                                            fillColor: AppColors.background,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 4, vertical: 8),
                                          ),
                                          onChanged: (val) => item.quantity =
                                              int.tryParse(val) ?? 1,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Scadenza
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item.expireDate,
                                          style: const TextStyle(fontSize: 13),
                                          decoration: InputDecoration(
                                            labelText: "Scadenza",
                                            filled: true,
                                            fillColor: AppColors.background,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                          ),
                                          onChanged: (val) =>
                                              item.expireDate = val,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Riga 3: Categoria
                                  DropdownButtonFormField<String>(
                                    initialValue: widget.state.categories
                                            .contains(item.category)
                                        ? item.category
                                        : 'Altro',
                                    isExpanded: true,
                                    icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primary),
                                    items: {
                                      ...widget.state.categories
                                          .where((c) => c != "Tutti"),
                                      'Altro'
                                    }.map((c) {
                                      return DropdownMenuItem(
                                          value: c,
                                          child: Text(c,
                                              overflow: TextOverflow.ellipsis));
                                    }).toList(),
                                    onChanged: (val) =>
                                        item.category = val ?? 'Altro',
                                    decoration: InputDecoration(
                                      labelText: "Categoria",
                                      filled: true,
                                      fillColor: AppColors.primaryLight
                                          .withOpacity(0.3),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottone "+" per aggiungere riga vuota
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          items.add(ItemModel(
                            id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString() +
                                items.length.toString(),
                            name: "",
                            expireDate: "Scadenza: da verificare",
                            quantity: 1,
                            category: "Altro",
                            isPantry: true,
                          ));
                        });
                      },
                      icon: Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.primary),
                      label: Text("Aggiungi prodotto manualmente",
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Annulla",
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    for (var i in items) {
                      if (i.name.trim().isNotEmpty) {
                        widget.state.addItem(i);
                      }
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Salvati ${items.where((i) => i.name.trim().isNotEmpty).length} prodotti in dispensa!"),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Conferma Tutti",
                      style: TextStyle(
                          color: AppColors.surfaceLight,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }


}
