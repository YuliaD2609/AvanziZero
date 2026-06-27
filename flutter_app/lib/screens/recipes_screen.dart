import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';
import '../services/ia/recipe_matcher_service.dart';
import '../services/live_recipe_harvesting_service.dart';
import '../theme/app_colors.dart';
import '../widgets/menus.dart';

class RecipesScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onCartPressed;

  const RecipesScreen({
    super.key,
    required this.state,
    required this.onCartPressed,
  });

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _selectedCategory = 'Tutte';
  bool? _withOven; // Opzione forno
  bool _isRandomMode = false;
  bool _isOffline = false;
  List<RecipeMatch> _recipes = [];
  bool _isLoading = true;
  bool _showFilters = false;

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
    _checkNetworkAndFetchLive();
  }

  Future<void> _checkNetworkAndFetchLive() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Controllo connettività e presenza rete reale
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _isOffline =
                false; // Rete presente! Rimuoviamo l'indicatore offline dinamicamente
          });
        }

        final pantryItems = widget.state.allItems
            .where((i) => i.isPantry)
            .map((i) => i.name)
            .toList();

        final liveRecipes =
            await LiveRecipeHarvestingService.harvestLiveRecipes(pantryItems);

        for (var rec in liveRecipes) {
          await RecipeMatcherService.insertRecipeFromLiveWeb(rec);
        }

        // Toast informativi rimossi per migliorare l'esperienza utente
      } else {
        if (mounted) {
          setState(() {
            _isOffline = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
    }

    await _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    final pantryItems = widget.state.allItems
        .where((i) => i.isPantry)
        .map((i) => i.name)
        .toList();

    final expiringPantryItems = widget.state.allItems
        .where((i) => i.isPantry && i.urgencyLevel >= 1)
        .map((i) => i.name)
        .toList();

    List<RecipeMatch> matches = [];
    if (_isRandomMode) {
      try {
        // Cerca prima le ricette live dal web come prioritario
        final liveRecipes =
            await LiveRecipeHarvestingService.harvestLiveRecipes(pantryItems);
        if (liveRecipes.isNotEmpty) {
          var filteredLive = liveRecipes.where((rec) {
            if (_selectedCategory != 'Tutte' && rec.category != _selectedCategory) {
              return false;
            }
            if (_withOven != null && rec.withOven != _withOven) {
              return false;
            }
            return true;
          }).toList();

          filteredLive.shuffle();
          final selectedLive = filteredLive.sublist(
              0, filteredLive.length > 200 ? 200 : filteredLive.length);
          for (var rec in selectedLive) {
            final newId =
                await RecipeMatcherService.insertRecipeFromLiveWeb(rec);
            matches.add(RecipeMatch(
              id: newId,
              name: rec.name,
              description: rec.description,
              source: rec.source,
              category: rec.category,
              prepTime: rec.prepTime,
              prepTimeMin: rec.prepTimeMin,
              difficulty: rec.difficulty,
              withOven: rec.withOven,
              instructions: rec.instructions,
              allIngredients: rec.allIngredients,
              missingIngredients: rec.missingIngredients,
              toleratedIngredients: rec.toleratedIngredients,
            ));
          }
          // Toast di avviso rimosso
        }
      } catch (e) {
        // Fallback silenzioso
      }

      // Se non si trovano ricette live (es. offline), passa al DB locale
      if (matches.isEmpty) {
        matches = await RecipeMatcherService.findRandomRecipes(
          pantryItems,
          selectedCategory: _selectedCategory,
          withOven: _withOven,
          count: 200,
        );
      }
    } else {
      matches = await RecipeMatcherService.findMatchingRecipes(
        pantryItems,
        expiringPantryItems: expiringPantryItems,
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

      body: Column(
        children: [
          // Header unificato
          HorizontalHeaderMenu(
            title: _isRandomMode ? 'Ricette Casuali' : 'Ricette',
            leftAction: IconButton(
              icon: Icon(Icons.filter_list_rounded, color: AppColors.textPrimary, size: 28),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
            customActions: [
              IconButton(
                tooltip: 'Ricette dalla Dispensa',
                icon: Icon(Icons.kitchen_outlined, color: !_isRandomMode ? AppColors.textPrimary : AppColors.textSecondary, size: 26),
                onPressed: () {
                  setState(() {
                    _isRandomMode = false;
                  });
                  _loadRecipes();
                },
              ),
              IconButton(
                tooltip: '5 Ricette Casuali',
                icon: Icon(Icons.shuffle_rounded, color: _isRandomMode ? AppColors.textPrimary : AppColors.textSecondary, size: 26),
                onPressed: () {
                  setState(() {
                    _isRandomMode = true;
                  });
                  _loadRecipes();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Sezione filtri con animazione
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: !_showFilters
                ? const SizedBox.shrink()
                : Container(
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
                // Chip categorie
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
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
                // Filtri forno
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
                    // Con forno
                    FilterChip(
                      selected: _withOven == true,
                      label: const Text('Con Forno'),
                      labelStyle: TextStyle(
                        color: _withOven == true
                            ? Colors.white
                            : AppColors.textSecondary,
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
                    // Senza forno
                    FilterChip(
                      selected: _withOven == false,
                      label: const Text('Senza Forno'),
                      labelStyle: TextStyle(
                        color: _withOven == false
                            ? Colors.white
                            : AppColors.textSecondary,
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
          ),
          // Banner dinamico Modalità Offline se non c'è rete
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.shade600,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Modalità Offline: Rete assente. Mostrando le ricette salvate in locale.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: _checkNetworkAndFetchLive,
                    child: const Text('Riprova',
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          // Lista ricette
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
                            Icon(Icons.no_meals_rounded,
                                size: 64,
                                color:
                                    AppColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Nessuna ricetta compatibile trovata.',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aggiungi più ingredienti alla tua dispensa!',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _checkNetworkAndFetchLive,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _recipes[index];
                            return _buildRecipeCard(recipe);
                          },
                        ),
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
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isReadyToCook
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.background,
                border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                recipe.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
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
            // Info cottura
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(recipe.prepTime,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(width: 16),
                  Icon(Icons.trending_up_rounded,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(recipe.difficulty,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(width: 16),
                  Icon(
                      recipe.withOven
                          ? Icons.microwave_rounded
                          : Icons.pan_tool_rounded,
                      color: AppColors.textSecondary,
                      size: 18),
                  const SizedBox(width: 4),
                  Text(recipe.withOven ? 'Con Forno' : 'In Padella',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            const Divider(height: 1),
            // Sezione ingredienti
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredienti Richiesti:',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.allIngredients.map((ing) {
                    final isMissing = recipe.missingIngredients.contains(ing);
                    final isTolerated =
                        recipe.toleratedIngredients.contains(ing);

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
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic),
                            ),
                          ]
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    'Procedimento:',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.instructions.replaceAllMapped(RegExp(r'\s+(\d+\.)'), (match) => '\n${match.group(1)}'),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            // Area Pulsanti di Azione
            Column(
              children: [
                if (!isReadyToCook)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(45),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.0),
                      ),
                      onPressed: () async {
                        final missingNames = recipe.missingIngredients.map((e) => e.name).toList();
                        await widget.state.addMissingIngredientsToShoppingList(missingNames);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                missingNames.length == 1
                                    ? "1 ingrediente aggiunto alla tua Lista della Spesa!"
                                    : "${missingNames.length} ingredienti aggiunti alla tua Lista della Spesa!",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          _loadRecipes();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 20, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            recipe.missingIngredients.length == 1
                                ? 'Aggiungi 1 mancante alla Spesa'
                                : 'Aggiungi ${recipe.missingIngredients.length} mancanti alla Spesa',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.50),
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Hai tutti gli ingredienti in dispensa!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Nuovo pulsante per aprire il sito della ricetta
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () async {
                      String url = recipe.source;
                      if (!url.startsWith('http')) {
                        final sourceLower = url.toLowerCase();
                        final encName = Uri.encodeComponent(recipe.name);
                        if (sourceLower.contains('giallozafferano')) {
                          url = 'https://www.giallozafferano.it/ricerca-ricette/$encName';
                        } else if (sourceLower.contains('cucchiaio')) {
                          url = 'https://www.cucchiaio.it/ricerca/?q=$encName';
                        } else if (sourceLower.contains('tavolartegusto')) {
                          url = 'https://www.tavolartegusto.it/?s=$encName';
                        } else if (sourceLower.contains('benedetta')) {
                          url = 'https://www.fattoincasadabenedetta.it/?s=$encName';
                        } else if (sourceLower.contains('misya')) {
                          url = 'https://www.misya.info/?s=$encName';
                        } else if (sourceLower.contains('chiarapassion')) {
                          url = 'https://www.chiarapassion.com/?s=$encName';
                        } else if (sourceLower.contains('cuore in pentola')) {
                          url = 'https://www.ilcuoreinpentola.it/?s=$encName';
                        } else if (sourceLower.contains('brodo di coccole')) {
                          url = 'https://www.brododicoccole.com/?s=$encName';
                        } else if (sourceLower.contains('food.com')) {
                          url = 'https://www.food.com/search/$encName';
                        } else {
                          url = 'https://www.giallozafferano.it/ricerca-ricette/$encName';
                        }
                      }
                      final uri = Uri.parse(url);
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        Fluttertoast.showToast(msg: 'Impossibile aprire il link della ricetta.');
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Vai al sito della ricetta',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

    // Base cappello
    path.moveTo(size.width * 0.25, size.height * 0.85);
    path.lineTo(size.width * 0.75, size.height * 0.85);

    path.moveTo(size.width * 0.25, size.height * 0.70);
    path.lineTo(size.width * 0.75, size.height * 0.70);

    // Contorno superiore
    path.moveTo(size.width * 0.25, size.height * 0.70);
    path.cubicTo(size.width * 0.05, size.height * 0.60, size.width * 0.15,
        size.height * 0.30, size.width * 0.35, size.height * 0.35);
    path.cubicTo(size.width * 0.40, size.height * 0.10, size.width * 0.60,
        size.height * 0.10, size.width * 0.65, size.height * 0.35);
    path.cubicTo(size.width * 0.85, size.height * 0.30, size.width * 0.95,
        size.height * 0.60, size.width * 0.75, size.height * 0.70);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
