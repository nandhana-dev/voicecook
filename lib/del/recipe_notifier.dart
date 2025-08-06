import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/recipe_hive.dart';

final recipeListNotifier = ValueNotifier<List<HiveRecipe>>([]);
final savedListNotifier = ValueNotifier<List<HiveRecipe>>([]);

void loadAllRecipes() {
  final box = Hive.box<HiveRecipe>('recipes');
  recipeListNotifier.value = box.values.toList();
}

void loadSavedRecipes() {
  final box = Hive.box<HiveRecipe>('saved_recipes');
  savedListNotifier.value = box.values.toList();
}
