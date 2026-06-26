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
  });
}

class RecipeMatcherService {
  static Database? _database;
  static bool _isUpdatingFromCloud = false;

  /// Inizializza il database copiandolo dagli asset se non esiste
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
    
    // Avvia l'aggiornamento silente da Firebase Storage in background
    _updateDatabaseFromCloudInBackground(path);

    return _database!;
  }

  /// Scarica e sostituisce il database da Firebase Storage in background se c'è una versione aggiornata
  static Future<void> _updateDatabaseFromCloudInBackground(String localPath) async {
    if (_isUpdatingFromCloud) return;
    _isUpdatingFromCloud = true;

    try {
      debugPrint('Controllo aggiornamenti del catalogo ricette da Firebase Storage in background...');
      final ref = FirebaseStorage.instance.ref('db/recipes_catalog.db');
      final tempPath = '$localPath.temp';
      final tempFile = File(tempPath);

      await ref.writeToFile(tempFile);

      // Chiudi il vecchio DB e sostituiscilo con il nuovo scaricato
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

  /// Interroga il database SQLite e calcola la differenza degli ingredienti per trovare le ricette compatibili
  static Future<List<RecipeMatch>> findMatchingRecipes(
    List<String> pantryItems, {
    String? selectedCategory,
    bool? withOven,
  }) async {
    final db = await getDatabase();

    // Costruzione query dinamica in base ai filtri
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

    // Normalizziamo i nomi dei prodotti in dispensa in minuscolo
    final normalizedPantry = pantryItems.map((e) => e.trim().toLowerCase()).toList();

    List<RecipeMatch> matches = [];

    for (var map in maps) {
      final recipeId = map['id'] as int;

      // Recuperiamo gli ingredienti per la ricetta
      final List<Map<String, dynamic>> ingredientMaps = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );

      List<RecipeIngredient> allIngredients = ingredientMaps.map((m) => RecipeIngredient.fromMap(m)).toList();
      List<RecipeIngredient> missingIngredients = [];

      for (var ing in allIngredients) {
        bool found = false;
        for (var pItem in normalizedPantry) {
          if (pItem.contains(ing.normalizedName) || ing.normalizedName.contains(pItem)) {
            found = true;
            break;
          }
        }
        if (!found) {
          missingIngredients.add(ing);
        }
      }

      // Filtro Tolleranza: massimo 2 ingredienti mancanti
      if (missingIngredients.length <= 2) {
        matches.add(RecipeMatch(
          id: recipeId,
          name: map['name'] as String,
          description: map['description'] as String?,
          source: map['source'] as String,
          category: map['category'] as String,
          prepTime: map['prep_time'] as String,
          prepTimeMin: map['prep_time_min'] as int,
          difficulty: map['difficulty'] as String,
          withOven: (map['with_oven'] as int) == 1,
          instructions: map['instructions'] as String,
          allIngredients: allIngredients,
          missingIngredients: missingIngredients,
        ));
      }
    }

    // Ranking per studenti: prima le ricette con meno ingredienti mancanti, poi le più veloci
    matches.sort((a, b) {
      int missingCompare = a.missingIngredients.length.compareTo(b.missingIngredients.length);
      if (missingCompare != 0) return missingCompare;
      return a.prepTimeMin.compareTo(b.prepTimeMin);
    });

    return matches;
  }
}
