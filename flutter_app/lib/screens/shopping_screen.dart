import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/menus.dart';
import '../theme/app_colors.dart';
import '../services/ai_scanner_service.dart';
import '../widgets/ocr_scanner_modal.dart';
import 'dart:math';

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
      final matchesCategory =
          widget.state.selectedShoppingCategory == "Tutti" ||
              item.category == widget.state.selectedShoppingCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
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
                  onCategorySelected: (category) =>
                      widget.state.selectCategory(category, 'shopping'),
                  onCategoryLongPressed: (category) =>
                      _showDeleteCategoryDialog(context, category, 'shopping'),
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

                      // Area principale: Lista della spesa e Pulsanti sovrapposti
                      Expanded(
                        child: Stack(
                          children: [
                            // 1. Lista della spesa scrollabile dietro i pulsanti
                            Positioned.fill(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24),
                                        child: Text(
                                          "Lista della spesa vuota per questa categoria.",
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
                                              130), // Padding extra per scrollare oltre i pulsanti
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
                                    onPressed: _handleSpesaFatta,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors
                                          .primaryLight, // Menta Chiaro
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                    child: Text(
                                      "Spesa fatta",
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors
                                            .textPrimary, // Verde Foresta Scuro
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Pulsanti flottanti in basso a destra
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Pulsante Predictive Shopping
                                      FloatingActionButton(
                                        heroTag: "predictive_btn",
                                        onPressed: () =>
                                            _showPredictiveShoppingModal(
                                                context),
                                        backgroundColor: AppColors.primaryLight,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Icon(Icons.auto_awesome_rounded,
                                            color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      // Pulsante Aggiungi un Elemento
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
      duration: const Duration(milliseconds: 200),
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
            offset: const Offset(0, 1),
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
                color: _checkedItems.contains(item.id)
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _checkedItems.contains(item.id)
                  ? Icon(Icons.check_rounded,
                      color: AppColors.surfaceLight, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

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
                  child: const Center(
                      child: Text("-",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${item.quantity}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
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
                  child: const Center(
                      child: Text("+",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
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
                final history = await widget.state.firebaseService
                        ?.getConsumptionHistory() ??
                    [];
                final pantryItems =
                    widget.state.allItems.where((i) => i.isPantry).toList();
                final shoppingItems =
                    widget.state.allItems.where((i) => i.isShopping).toList();
                final groupSize = widget.state.groupMembers.isNotEmpty
                    ? widget.state.groupMembers.length
                    : 1;

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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Errore IA: $e")));
                }
              }
            });
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Predictive Shopping",
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isAILoading
                      ? "L'IA sta analizzando lo storico dei consumi..."
                      : "I suggerimenti intelligenti basati sulle tue abitudini.",
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.textSecondary,
                      fontSize: 14),
                ),
                const SizedBox(height: 24),
                if (isAILoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text("Elaborazione IA in corso...",
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  )
                else if (scarcityItems.isEmpty && expiringItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                          "Nessun suggerimento al momento! Non ci sono elementi in scadenza o che stanno per finire.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else ...[
                  if (scarcityItems.isNotEmpty) ...[
                    Text("Pochi rimasti",
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: scarcityItems
                          .map((item) => _buildSuggestionChip(item))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (expiringItems.isNotEmpty) ...[
                    Text("Vicino alla scadenza",
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            color: AppColors.error)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: expiringItems
                          .map((item) => _buildSuggestionChip(item))
                          .toList(),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
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
      label: Text("+ ${item.name}",
          style: TextStyle(
              color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      onPressed: () {
        final newItemId = DateTime.now().millisecondsSinceEpoch.toString();
        final newItem = ItemModel(
          id: newItemId,
          name: item.name,
          category: item.category,
          isShopping: true,
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
        title: Text("Nuova Categoria Spesa",
            style:
                TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(hintText: "Nome categoria"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Annulla")),
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
          title: Text("Aggiungi Elemento Spesa",
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
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  widget.state.addItem(ItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    category: selectedCat,
                    isShopping: true,
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

  void _handleSpesaFatta() {
    if (_checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Seleziona almeno un prodotto per completare la spesa!")),
      );
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Scontrino?"),
            content: const Text(
                "Vuoi scansionare lo scontrino della spesa per inserire i prodotti automaticamente e unirli a quelli della tua lista?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Procedi normalmente senza scontrino
                  widget.state.markSelectedShoppingDone(_checkedItems.toList());
                  setState(() {
                    _checkedItems.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          "Spesa Fatta! Prodotti selezionati trasferiti in Dispensa con successo."),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: Text("No, procedi",
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openScannerAndMerge();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text("Sì, scansiona",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    List<int> v0 = List<int>.filled(b.length + 1, 0);
    List<int> v1 = List<int>.filled(b.length + 1, 0);
    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }
    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  double _similarityScore(String a, String b) {
    int maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    return 1.0 - (_levenshteinDistance(a, b) / maxLen);
  }

  void _openScannerAndMerge() async {
    final scannedItems = await showModalBottomSheet<List<ItemModel>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OcrScannerModal(state: widget.state),
    );

    if (scannedItems == null) return; // Utente ha annullato

    List<ItemModel> mergedItems = [];
    List<ItemModel> checkedItemsList = widget.state.allItems
        .where((i) => _checkedItems.contains(i.id))
        .toList();
    Set<String> matchedShoppingItemIds = {};

    for (var scanned in scannedItems) {
      String cleanScannedName = scanned.name.toLowerCase().trim();
      bool foundMatch = false;

      for (var checked in checkedItemsList) {
        if (matchedShoppingItemIds.contains(checked.id)) continue;

        String cleanCheckedName = checked.name.toLowerCase().trim();

        // Match esatto, contenuto, o similarity > 60%
        if (cleanScannedName.contains(cleanCheckedName) ||
            cleanCheckedName.contains(cleanScannedName) ||
            _similarityScore(cleanScannedName, cleanCheckedName) > 0.6) {
          // Priorità Lista Spesa (Nome, Categoria), ma Quantità dallo Scontrino
          mergedItems.add(ItemModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                checked.name.hashCode.toString(),
            name: checked.name,
            expireDate: scanned.expireDate,
            quantity: scanned.quantity,
            category: checked.category,
            isPantry: true,
          ));

          matchedShoppingItemIds.add(checked.id);
          foundMatch = true;
          break;
        }
      }

      if (!foundMatch) {
        mergedItems.add(scanned);
      }
    }

    // Aggiungiamo i non matchati della lista spesa
    for (var checked in checkedItemsList) {
      if (!matchedShoppingItemIds.contains(checked.id)) {
        mergedItems.add(ItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              checked.name.hashCode.toString(),
          name: checked.name,
          expireDate: "Scadenza: da verificare",
          quantity: checked.quantity,
          category: checked.category,
          isPantry: true,
        ));
      }
    }

    _showMergedItemsConfirmationDialog(mergedItems);
  }

  void _showMergedItemsConfirmationDialog(List<ItemModel> items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Conferma Dispensa",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.all(16),
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
                          return Card(
                            key: ObjectKey(item),
                            color: Colors.white,
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
                                  Row(
                                    children: [
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
                    for (var item in items) {
                      widget.state.addItem(item);
                    }
                    // Cancelliamo gli elementi dalla lista della spesa che erano spuntati
                    for (var id in _checkedItems) {
                      widget.state.deleteItem(id);
                    }
                    setState(() {
                      _checkedItems.clear();
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            "Spesa Fatta e fusa con lo scontrino! Elementi spostati in Dispensa."),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text("Salva in Dispensa",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
