import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/recipe_matcher_service.dart';
import '../theme/app_colors.dart';

class RecipesScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;

  const RecipesScreen({
    super.key,
    required this.state,
    required this.onHomePressed,
    required this.onCartPressed,
  });

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _selectedCategory = 'Tutte';
  bool? _withOven; // null = tutti, true = con forno, false = senza forno
  List<RecipeMatch> _recipes = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Tutte',
    'Primi Piatti',
    'Secondi Piatti',
    'Piatti Unici',
    'Dolci',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    final pantryItems = widget.state.allItems
        .where((i) => i.isPantry)
        .map((i) => i.name)
        .toList();

    final matches = await RecipeMatcherService.findMatchingRecipes(
      pantryItems,
      selectedCategory: _selectedCategory,
      withOven: _withOven,
    );

    setState(() {
      _recipes = matches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(Icons.room_service_rounded, color: AppColors.primary, size: 28),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Text(
              'Ricette Magiche',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
            onPressed: widget.onCartPressed,
          ),
          IconButton(
            icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
            onPressed: widget.onHomePressed,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sezione Filtri: Categorie ed opzione Forno
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip Categorie
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            _loadRecipes();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Checkbox Forno / Senza Forno
                Row(
                  children: [
                    Text(
                      'Cottura al forno:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Checkbox Con Forno
                    FilterChip(
                      selected: _withOven == true,
                      label: const Text('Con Forno'),
                      labelStyle: TextStyle(
                        color: _withOven == true ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.primaryDark,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _withOven = selected ? true : null;
                        });
                        _loadRecipes();
                      },
                    ),
                    const SizedBox(width: 8),
                    // Checkbox Senza Forno
                    FilterChip(
                      selected: _withOven == false,
                      label: const Text('Senza Forno'),
                      labelStyle: TextStyle(
                        color: _withOven == false ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.primaryDark,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _withOven = selected ? false : null;
                        });
                        _loadRecipes();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista delle Ricette
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _recipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.no_meals_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Nessuna ricetta compatibile trovata.',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aggiungi più ingredienti alla tua dispensa!',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return _buildRecipeCard(recipe);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(RecipeMatch recipe) {
    final bool isReadyToCook = recipe.missingIngredients.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione Card: Nome e Tag Fonte
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isReadyToCook ? AppColors.primary.withOpacity(0.15) : AppColors.background,
                border: Border(bottom: Border.all(color: AppColors.border, width: 1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.description,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          recipe.source,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Info su Tempo, Difficoltà e Forno
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(recipe.prepTime, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(width: 16),
                  Icon(Icons.trending_up_rounded, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(recipe.difficulty, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(width: 16),
                  Icon(recipe.withOven ? Icons.microwave_rounded : Icons.pan_tool_rounded, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(recipe.withOven ? 'Con Forno' : 'In Padella/Senza Forno', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            const Divider(height: 1),
            // Sezione Ingredienti
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredienti Richiesti:',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.allIngredients.map((ing) {
                    final isMissing = recipe.missingIngredients.contains(ing);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isMissing ? Icons.warning_rounded : Icons.check_circle_rounded,
                            color: isMissing ? Colors.orange : Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ing.name} (${ing.quantity})',
                            style: TextStyle(
                              color: isMissing ? Colors.orange.shade700 : AppColors.textPrimary,
                              fontWeight: isMissing ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          if (isMissing) ...[
                            const Spacer(),
                            Text(
                              'Manca in Dispensa',
                              style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Text(
                    'Procedimento:',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.instructions,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            // Pulsante di Azione (Aggiungi Mancanti alla Spesa)
            if (!isReadyToCook)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () async {
                    final missingNames = recipe.missingIngredients.map((e) => e.name).toList();
                    await widget.state.addMissingIngredientsToShoppingList(missingNames);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "🛒 ${missingNames.length} ingredienti aggiunti alla tua Lista della Spesa!",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: AppColors.primaryDark,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      // Ricarica per aggiornare lo stato
                      _loadRecipes();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Aggiungi ${recipe.missingIngredients.length} mancanti alla Spesa',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Hai tutti gli ingredienti in Dispensa! Pronto a cucinare!',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
