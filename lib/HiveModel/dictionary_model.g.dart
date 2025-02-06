// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DictionaryWordAdapter extends TypeAdapter<DictionaryWord> {
  @override
  final int typeId = 0;

  @override
  DictionaryWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DictionaryWord(
      id: fields[0] as int,
      word: fields[1] as String,
      partOfSpeech: fields[2] as String,
      meaning: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DictionaryWord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.partOfSpeech)
      ..writeByte(3)
      ..write(obj.meaning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictionaryWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
