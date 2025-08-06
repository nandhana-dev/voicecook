import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/recipe_hive.dart';
import 'creatorpage.dart';
import 'package:hive/hive.dart';


class RecipeDetailPage extends StatefulWidget {
  final HiveRecipe recipe;


  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  void _playAudio(String path) async {
    if (await File(path).exists()) {
      await player.play(DeviceFileSource(path));
      print("🎵 Playing audio from: $path");
    } else {
      print("❌ Audio file not found at: $path");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    print("🎧 Received audio path: ${widget.recipe.audioPath}");
  }

  


  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(recipe.imagePath),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _playAudio(widget.recipe.audioPath),
                  icon: Icon(Icons.play_arrow),
                  label: Text(isPlaying ? "Pause" : "Play Audio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),


                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_add_outlined, color: Colors.deepOrange),
                  onPressed: () async {
                    final savedBox = Hive.box<HiveRecipe>('saved_recipes');

                    // ✅ Check if this recipe is already saved (by title & creator)
                    final alreadySaved = savedBox.values.any((r) =>
                      r.title == widget.recipe.title &&
                      r.creatorId == widget.recipe.creatorId);

                    if (alreadySaved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Already saved!')),
                      );
                      return;
                    }

                    // ✅ Save only if not already present
                    await savedBox.add(HiveRecipe(
                      title: widget.recipe.title,
                      ingredients: widget.recipe.ingredients,
                      imagePath: widget.recipe.imagePath,
                      audioPath: widget.recipe.audioPath,
                      creatorId: widget.recipe.creatorId,
                      creatorName: widget.recipe.creatorName,
                      creatorProfilePicPath: widget.recipe.creatorProfilePicPath,
                      creatorContact: widget.recipe.creatorContact,
                      creatorUPI: widget.recipe.creatorUPI,
                    ));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Recipe saved!')),
                    );
                  },
                ),


                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatorPage(
                          creatorId: recipe.creatorId,
                          creatorName: recipe.creatorName,
                          creatorProfilePicPath: recipe.creatorProfilePicPath,
                          creatorContact: recipe.creatorContact,
                          creatorUpi: recipe.creatorUPI,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: FileImage(File(recipe.creatorProfilePicPath)),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    recipe.ingredients.join(', '),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
           
          ],
        ),
      ),
    );
  }
}
