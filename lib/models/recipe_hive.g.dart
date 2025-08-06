// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveRecipeAdapter extends TypeAdapter<HiveRecipe> {
  @override
  final int typeId = 0;

  @override
  HiveRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveRecipe(
      title: fields[0] as String,
      ingredients: (fields[1] as List).cast<String>(),
      imagePath: fields[2] as String,
      audioPath: fields[3] as String,
      creatorId: fields[4] as String,
      creatorName: fields[5] as String,
      creatorProfilePicPath: fields[6] as String,
      creatorContact: fields[7] as String,
      creatorUPI: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveRecipe obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.ingredients)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.audioPath)
      ..writeByte(4)
      ..write(obj.creatorId)
      ..writeByte(5)
      ..write(obj.creatorName)
      ..writeByte(6)
      ..write(obj.creatorProfilePicPath)
      ..writeByte(7)
      ..write(obj.creatorContact)
      ..writeByte(8)
      ..write(obj.creatorUPI);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
