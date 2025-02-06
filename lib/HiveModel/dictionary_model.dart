import 'package:hive/hive.dart';

part 'dictionary_model.g.dart';

@HiveType(typeId: 0)
class DictionaryWord {
  @HiveField(0)
  final int id; // Unique identifier for the word

  @HiveField(1)
  final String word; // The actual word

  @HiveField(2)
  final String partOfSpeech; // e.g., noun, verb, adjective

  @HiveField(3)
  final String meaning; // Definition of the word

  // Constructor
  DictionaryWord({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.meaning,
  });

  @override
  String toString() {
    return 'DictionaryWord(id: $id, word: $word, partOfSpeech: $partOfSpeech, meaning: $meaning)';
  }
}
