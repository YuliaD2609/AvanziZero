import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecipeIngredient {
  final String name;
  final String quantity;
  final String normalizedName;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.normalizedName,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String,
      quantity: map['quantity'] as String,
      normalizedName: map['normalized_name'] as String,
    );
  }
}

class RecipeMatch {
  final int id;
  final String name;
  final String description;
  final String source;
  final String category;
  final String prepTime;
  final int prepTimeMin;
  final String difficulty;
  final bool withOven;
  final String instructions;
  final List<RecipeIngredient> allIngredients;
  final List<RecipeIngredient> missingIngredients;
  final List<RecipeIngredient> toleratedIngredients;

  RecipeMatch({
    required this.id,
    required this.name,
    required this.description,
    required this.source,
    required this.category,
    required this.prepTime,
    required this.prepTimeMin,
    required this.difficulty,
    required this.withOven,
    required this.instructions,
    required this.allIngredients,
    required this.missingIngredients,
    required this.toleratedIngredients,
  });
}

class RecipeMatcherService {
  static Database? _database;
  static bool _isUpdatingFromCloud = false;

  // Inizializza database sqlite
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'recipes_catalog.db');

    final exists = await databaseExists(path);

    if (!exists) {
      debugPrint('Copia del database SQLite ricette dagli asset...');
      try {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load('assets/db/recipes_catalog.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint('Errore durante la copia del database: $e');
      }
    }

    _database = await openDatabase(path, version: 1);
    
    // Avvia aggiornamento silente
    _updateDatabaseFromCloudInBackground(path);

    return _database!;
  }

  // Sostituisce database da cloud
  static Future<void> _updateDatabaseFromCloudInBackground(String localPath) async {
    if (_isUpdatingFromCloud) return;
    _isUpdatingFromCloud = true;

    try {
      debugPrint('Controllo aggiornamenti del catalogo ricette da Firebase Storage in background...');
      final ref = FirebaseStorage.instance.ref('db/recipes_catalog.db');
      final tempPath = '$localPath.temp';
      final tempFile = File(tempPath);

      await ref.writeToFile(tempFile);

      // Chiude vecchio db
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      if (await tempFile.exists()) {
        await tempFile.copy(localPath);
        await tempFile.delete();
        debugPrint('Database catalogo ricette aggiornato con successo dal Cloud!');
      }
    } catch (e) {
      debugPrint('Aggiornamento da Firebase Storage saltato (nessuna connessione o file non presente): $e');
    } finally {
      _isUpdatingFromCloud = false;
    }
  }

  // Trova ricette compatibili
  static Future<List<RecipeMatch>> findMatchingRecipes(
    List<String> pantryItems, {
    String? selectedCategory,
    bool? withOven,
  }) async {
    final db = await getDatabase();

    // Costruisce query dinamica
    String whereClause = '1 = 1';
    List<dynamic> whereArgs = [];

    if (selectedCategory != null && selectedCategory.isNotEmpty && selectedCategory != 'Tutte') {
      whereClause += ' AND category = ?';
      whereArgs.add(selectedCategory);
    }

    if (withOven != null) {
      whereClause += ' AND with_oven = ?';
      whereArgs.add(withOven ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: whereClause,
      whereArgs: whereArgs,
    );

    // Normalizza nomi prodotti
    final normalizedPantry = pantryItems.map((e) => e.trim().toLowerCase()).toList();

    List<RecipeMatch> matches = [];

    for (var map in maps) {
      final recipeId = map['id'] as int;

      // Recupera ingredienti ricetta
      final List<Map<String, dynamic>> ingredientMaps = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );

      List<RecipeIngredient> allIngredients = ingredientMaps.map((m) => RecipeIngredient.fromMap(m)).toList();
      List<RecipeIngredient> missingIngredients = [];
      List<RecipeIngredient> toleratedIngredients = [];

      final List<String> stapleKeywords = ['zucchero', 'farina', 'sale', 'pepe', 'acqua', 'olio'];

      for (var ing in allIngredients) {
        bool found = false;
        for (var pItem in normalizedPantry) {
          if (pItem.contains(ing.normalizedName) || ing.normalizedName.contains(pItem)) {
            found = true;
            break;
          }
        }
        if (!found) {
          bool isStaple = stapleKeywords.any((staple) => ing.normalizedName.contains(staple) || ing.name.toLowerCase().contains(staple));
          if (isStaple) {
            toleratedIngredients.add(ing);
          } else {
            missingIngredients.add(ing);
          }
        }
      }

      matches.add(RecipeMatch(
        id: recipeId,
        name: map['name'] as String,
        description: (map['description'] as String?) ?? '',
        source: map['source'] as String,
        category: map['category'] as String,
        prepTime: map['prep_time'] as String,
        prepTimeMin: map['prep_time_min'] as int,
        difficulty: map['difficulty'] as String,
        withOven: (map['with_oven'] as int) == 1,
        instructions: map['instructions'] as String,
        allIngredients: allIngredients,
        missingIngredients: missingIngredients,
        toleratedIngredients: toleratedIngredients,
      ));
    }

    // Ordina ricette compatibili
    matches.sort((a, b) {
      int missingCompare = a.missingIngredients.length.compareTo(b.missingIngredients.length);
      if (missingCompare != 0) return missingCompare;
      return a.prepTimeMin.compareTo(b.prepTimeMin);
    });

    if (matches.length > 5) {
      matches = matches.sublist(0, 5);
    }

    return matches;
  }

  // Trova ricette casuali
  static Future<List<RecipeMatch>> findRandomRecipes(
    List<String> pantryItems, {
    String? selectedCategory,
    bool? withOven,
    int count = 5,
  }) async {
    final db = await getDatabase();

    String whereClause = '1 = 1';
    List<dynamic> whereArgs = [];

    if (selectedCategory != null && selectedCategory.isNotEmpty && selectedCategory != 'Tutte') {
      whereClause += ' AND category = ?';
      whereArgs.add(selectedCategory);
    }

    if (withOven != null) {
      whereClause += ' AND with_oven = ?';
      whereArgs.add(withOven ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: count,
    );

    final normalizedPantry = pantryItems.map((e) => e.trim().toLowerCase()).toList();
    List<RecipeMatch> matches = [];
    final List<String> stapleKeywords = ['zucchero', 'farina', 'sale', 'pepe', 'acqua', 'olio'];

    for (var map in maps) {
      final recipeId = map['id'] as int;

      final List<Map<String, dynamic>> ingredientMaps = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );

      List<RecipeIngredient> allIngredients = ingredientMaps.map((m) => RecipeIngredient.fromMap(m)).toList();
      List<RecipeIngredient> missingIngredients = [];
      List<RecipeIngredient> toleratedIngredients = [];

      for (var ing in allIngredients) {
        bool found = false;
        for (var pItem in normalizedPantry) {
          if (pItem.contains(ing.normalizedName) || ing.normalizedName.contains(pItem)) {
            found = true;
            break;
          }
        }
        if (!found) {
          bool isStaple = stapleKeywords.any((staple) => ing.normalizedName.contains(staple) || ing.name.toLowerCase().contains(staple));
          if (isStaple) {
            toleratedIngredients.add(ing);
          } else {
            missingIngredients.add(ing);
          }
        }
      }

      matches.add(RecipeMatch(
        id: recipeId,
        name: map['name'] as String,
        description: (map['description'] as String?) ?? '',
        source: map['source'] as String,
        category: map['category'] as String,
        prepTime: map['prep_time'] as String,
        prepTimeMin: map['prep_time_min'] as int,
        difficulty: map['difficulty'] as String,
        withOven: (map['with_oven'] as int) == 1,
        instructions: map['instructions'] as String,
        allIngredients: allIngredients,
        missingIngredients: missingIngredients,
        toleratedIngredients: toleratedIngredients,
      ));
    }

    return matches;
  }
}
