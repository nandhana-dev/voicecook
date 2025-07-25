class Recipe {
  final int? id;
  final String title;
  final String ingredients;
  final String imagePath;    // image file path
  final String audioPath;    // audio file path
  final String creatorId;  // can be email, UID, or any unique string


  Recipe({
    this.id,
    required this.title,
    required this.ingredients,
    required this.imagePath,
    required this.audioPath,
    required this.creatorId,   // <-- new field
  });

  // Convert a Recipe into a Map. For inserting into DB.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'creatorId': creatorId,
    };
  }

  // Convert a Map into a Recipe. For reading from DB.
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      ingredients: map['ingredients'],
      imagePath: map['imagePath'],
      audioPath: map['audioPath'],
      creatorId: map['creatorId'],
    );
  }
}
