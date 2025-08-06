import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicecook/screens/add_recipe_screen.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'screens/recipe_detail.dart';
import 'screens/creatorpage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/recipe_hive.dart';
import 'del/recipe_notifier.dart';
import 'screens/saved_recipes_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HiveRecipeAdapter());
   
  
  await Hive.openBox<HiveRecipe>('recipes');
  await Hive.openBox<HiveRecipe>('saved_recipes');
 

  runApp(const VoiceCookApp()); // Now run the app
}


class VoiceCookApp extends StatelessWidget {
  const VoiceCookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VoiceCook',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: HomeScreen(),
    );
  }
}



class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('voicecook.speech.recognizer');
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();

    _loadRecipes();

    recipeListNotifier.addListener(() {
      setState(() {}); // Rebuild UI when recipe list changes
    });
  }



   @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final box = Hive.box<HiveRecipe>('recipes');
    recipeListNotifier.value = box.values.toList();  // ✅ global update
  }




 void _playAudio(String path) async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(path));
  }


  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Microphone permission denied');
      return;
    }

    try {
      final String result = await platform.invokeMethod('startSpeechRecognition');
      setState(() {
        _searchController.text = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke speech recognition: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("📦 HomeScreen recipes count: ${recipeListNotifier.value.length}");

    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Welcome Text
            Container(
              color: Colors.orange[100],
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Welcome! Get quick recipes with what you have',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Search Bar Row with profile icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  // Expanded Search Bar on the left
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Row(
                        children: [
                          // Permanent grey text
                          Text(
                            'I have  ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          // Typing area
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'egg,onion search recipes...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          // Voice search icon (using logo)
                          GestureDetector(
                            onTap: _startListening,
                            child: Image.asset(
                              'assets/images/voicecook_logo.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Profile Icon on the right
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatorPage(
                            creatorId: 'housewife123',
                            creatorName: 'Lakshmi',
                            creatorProfilePicPath: 'assets/images/default.png', // or any dummy asset
                            creatorContact: '9876543210',
                            creatorUpi: 'lakshmi@okaxis',
                          ),

                        ),
                      ).then((shouldRefresh) {
                        if (shouldRefresh == true) {
                          _loadRecipes();
                        }
                      });
                    },
                    child: Icon(Icons.account_circle, size: 30, color: Colors.green[700]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Display saved recipes

            
            Expanded(
              child: ValueListenableBuilder<List<HiveRecipe>>(
                valueListenable: recipeListNotifier,
                builder: (context, recipes, _) {
                  if (recipes.isEmpty) {
                    return Center(child: Text('No recipes yet!'));
                  }

                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                            leading: recipe.imagePath.isNotEmpty
                                ? Image.file(
                                    File(recipe.imagePath),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported),
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
                  );
                },
              ),
            ),



            // Bottom Section: Home | Made with love by + Creator | Saved
            Container(
              color: Colors.orange[100],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Home
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, color: Colors.deepOrange),
                      Text(
                        "Home",
                        style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                      ),
                    ],
                  ),

                  // Center: Made with love + Creator Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Made with love by',
                        style: TextStyle(fontSize: 13, color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, size: 18, color: Colors.white),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddRecipeScreen()),
                            );
                            _loadRecipes(); // ✅ Refresh after returning from AddRecipeScreen 
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  // Right: Saved list
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedRecipesPage()),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bookmark, color: Colors.deepOrange),
                        Text("Saved", style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
