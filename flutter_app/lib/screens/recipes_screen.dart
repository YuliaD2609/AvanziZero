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
  bool _isRandomMode = false;
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

    List<RecipeMatch> matches;
    if (_isRandomMode) {
      matches = await RecipeMatcherService.findRandomRecipes(
        pantryItems,
        selectedCategory: _selectedCategory,
        withOven: _withOven,
        count: 5,
      );
    } else {
      matches = await RecipeMatcherService.findMatchingRecipes(
        pantryItems,
        selectedCategory: _selectedCategory,
        withOven: _withOven,
      );
    }

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
            ChefHatIcon(color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              _isRandomMode ? 'Ricette Casuali' : 'Ricette',
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
            tooltip: 'Ricette dalla Dispensa',
            icon: Icon(Icons.kitchen_outlined, color: !_isRandomMode ? AppColors.primary : AppColors.textSecondary, size: 26),
            onPressed: () {
              setState(() {
                _isRandomMode = false;
              });
              _loadRecipes();
            },
          ),
          IconButton(
            tooltip: '5 Ricette Casuali',
            icon: Icon(Icons.casino_outlined, color: _isRandomMode ? AppColors.primary : AppColors.textSecondary, size: 26),
            onPressed: () {
              setState(() {
                _isRandomMode = true;
              });
              _loadRecipes();
            },
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
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
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
                  Text(recipe.withOven ? 'Con Forno' : 'In Padella', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
                    final isTolerated = recipe.toleratedIngredients.contains(ing);
                    
                    IconData iconData;
                    Color iconColor;
                    String statusText = '';
                    Color textColor = AppColors.textPrimary;
                    FontWeight fontWeight = FontWeight.normal;

                    if (isMissing) {
                      iconData = Icons.warning_rounded;
                      iconColor = Colors.orange;
                      statusText = 'Manca in Dispensa';
                      textColor = Colors.orange.shade700;
                      fontWeight = FontWeight.w600;
                    } else if (isTolerated) {
                      iconData = Icons.fiber_manual_record;
                      iconColor = AppColors.textSecondary.withOpacity(0.6);
                      statusText = 'Ingrediente base';
                      textColor = AppColors.textSecondary;
                    } else {
                      iconData = Icons.check_circle_rounded;
                      iconColor = Colors.green;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(
                              iconData,
                              color: iconColor,
                              size: isTolerated ? 14 : 18,
                            ),
                          ),
                          SizedBox(width: isTolerated ? 12 : 8),
                          Expanded(
                            child: Text(
                              '${ing.name} (${ing.quantity})',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: fontWeight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (statusText.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: TextStyle(color: textColor, fontSize: 12, fontStyle: FontStyle.italic),
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

class ChefHatIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ChefHatIcon({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChefHatPainter(color: color),
    );
  }
}

class _ChefHatPainter extends CustomPainter {
  final Color color;

  _ChefHatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Base del cappello (fascia inferiore stilizzata)
    path.moveTo(size.width * 0.25, size.height * 0.85);
    path.lineTo(size.width * 0.75, size.height * 0.85);
    
    path.moveTo(size.width * 0.25, size.height * 0.70);
    path.lineTo(size.width * 0.75, size.height * 0.70);

    // Contorno superiore a nuvola stilizzato (3 arcate morbide e continue)
    path.moveTo(size.width * 0.25, size.height * 0.70);
    path.cubicTo(size.width * 0.05, size.height * 0.60, size.width * 0.15, size.height * 0.30, size.width * 0.35, size.height * 0.35);
    path.cubicTo(size.width * 0.40, size.height * 0.10, size.width * 0.60, size.height * 0.10, size.width * 0.65, size.height * 0.35);
    path.cubicTo(size.width * 0.85, size.height * 0.30, size.width * 0.95, size.height * 0.60, size.width * 0.75, size.height * 0.70);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
