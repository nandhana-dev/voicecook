import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import '../models/recipe_hive.dart';
import 'recipe_detail.dart';

class SavedRecipesPage extends StatelessWidget {
  const SavedRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedBox = Hive.box<HiveRecipe>('saved_recipes');
    final savedRecipes = savedBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Recipes"),
        backgroundColor: Colors.orange,
      ),
      body: savedRecipes.isEmpty
          ? Center(child: Text("No saved recipes yet!"))
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: File(recipe.imagePath).existsSync()
                          ? Image.file(
                              File(recipe.imagePath),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image),
                      title: Text(recipe.title),
                      subtitle: Text(
                        recipe.ingredients.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
