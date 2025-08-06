import 'package:hive/hive.dart';

part 'recipe_hive.g.dart'; // Hive will generate this file

@HiveType(typeId: 0)
class HiveRecipe extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<String> ingredients;

  @HiveField(2)
  String imagePath; // file path of image stored locally

  @HiveField(3)
  String audioPath; // file path of audio stored locally

  @HiveField(4)
  String creatorId;

  // ✅ New fields below:

  @HiveField(5)
  String creatorName;

  @HiveField(6)
  String creatorProfilePicPath;

  @HiveField(7)
  String creatorContact;

  @HiveField(8)
  String creatorUPI;

  HiveRecipe({
    required this.title,
    required this.ingredients,
    required this.imagePath,
    required this.audioPath,
    required this.creatorId,
    required this.creatorName,
    required this.creatorProfilePicPath,
    required this.creatorContact,
    required this.creatorUPI,
  });
}
