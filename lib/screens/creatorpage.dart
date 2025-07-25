import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/recipe.dart';
import 'dart:io';

class CreatorPage extends StatefulWidget {
  final String creatorId; // ID of the profile being viewed
  final String currentUserId; // ID of the logged-in user

  CreatorPage({required this.creatorId, required this.currentUserId});

  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  List<Recipe> _creatorRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadCreatorRecipes();
  }

  Future<void> _loadCreatorRecipes() async {
    final allRecipes = await DatabaseHelper().getRecipes();
    setState(() {
      _creatorRecipes = allRecipes
          .where((recipe) => recipe.creatorId == widget.creatorId)
          .toList();
    });
  }

  Future<void> _deleteRecipe(int recipeId) async {
    final db = await DatabaseHelper().database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
    _loadCreatorRecipes(); // Refresh list
  }

  void _confirmDelete(int recipeId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Recipe"),
        content: Text("Are you sure you want to delete this recipe?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecipe(recipeId);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Creator's Recipes"),
      ),
      body: _creatorRecipes.isEmpty
          ? Center(child: Text("No recipes uploaded yet."))
          : ListView.builder(
              itemCount: _creatorRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _creatorRecipes[index];
                final isOwner = recipe.creatorId == widget.currentUserId;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: recipe.imagePath != null
                        ? Image.file(
                          File(recipe.imagePath!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          )
                        : Icon(Icons.image, size: 40),
                    title: Text(recipe.title),
                    subtitle: Text(
                      recipe.ingredients,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isOwner
                        ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(recipe.id!),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
