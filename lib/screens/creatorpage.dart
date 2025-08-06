import 'package:flutter/material.dart';
import '../models/recipe_hive.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../del/recipe_notifier.dart';



class CreatorPage extends StatefulWidget {
  final String creatorId;
  final String creatorName;
  final String creatorProfilePicPath;
  final String creatorContact;
  final String creatorUpi;

  const CreatorPage({
    required this.creatorId,
    required this.creatorName,
    required this.creatorProfilePicPath,
    required this.creatorContact,
    required this.creatorUpi,
    super.key,
  });

  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  List<HiveRecipe> _creatorRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadCreatorRecipes();
  }

  void _loadCreatorRecipes() {
    final box = Hive.box<HiveRecipe>('recipes');
    final allRecipes = box.values.toList();

    setState(() {
      _creatorRecipes = allRecipes
          .where((recipe) => recipe.creatorId == widget.creatorId)
          .toList();
    });
  }

  void _deleteRecipe(int index) async {
  final box = Hive.box<HiveRecipe>('recipes');
  final savedBox = Hive.box<HiveRecipe>('saved_recipes');

  final deletedRecipe = _creatorRecipes[index];

  // 1. Delete from recipes
  await box.deleteAt(index);

  // 2. Delete from saved_recipes (if present)
  final savedKeysToDelete = savedBox.keys.where((key) {
    final recipe = savedBox.get(key);
    return recipe?.title == deletedRecipe.title &&
           recipe?.creatorId == deletedRecipe.creatorId;
  }).toList();

  for (var key in savedKeysToDelete) {
    await savedBox.delete(key);
  }

  // 3. Refresh both notifiers
  loadAllRecipes();
  loadSavedRecipes();

  // 4. Refresh creator page locally
  _loadCreatorRecipes();
}



  void _confirmDelete(int index) {
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
              Navigator.pop(context, true);
              _deleteRecipe(index);
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
      appBar: AppBar(title: Text("${widget.creatorName}'s Recipes")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: File(widget.creatorProfilePicPath).existsSync()
              ? FileImage(File(widget.creatorProfilePicPath))
              : const AssetImage('assets/images/default.png') as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text(widget.creatorName, style: TextStyle(fontSize: 20)),
          if (widget.creatorContact.isNotEmpty)
            Text('📞 ${widget.creatorContact}'),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              final uri = Uri.parse(
                'upi://pay?pa=${widget.creatorUpi}&pn=${Uri.encodeComponent(widget.creatorName)}&cu=INR',
              );
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: Icon(Icons.favorite),
            label: Text("Send Gift via GPay"),
          ),
          const Divider(),
          Expanded(
            child: _creatorRecipes.isEmpty
                ? Center(child: Text("No recipes uploaded yet."))
                : ListView.builder(
                    itemCount: recipeListNotifier.value.length,
                    itemBuilder: (context, index) {
                      final recipe = recipeListNotifier.value[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: recipe.imagePath.isNotEmpty && File(recipe.imagePath).existsSync()
                              ? Image.file(
                                  File(recipe.imagePath),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.image, size: 40),
                          title: Text(recipe.title),
                          subtitle: Text(
                            recipe.ingredients.join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: recipe.creatorId == widget.creatorId
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(index),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
