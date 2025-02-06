import 'package:csv/csv.dart';
import 'package:dictionary_project/HiveModel/dictionary_model.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  Box<DictionaryWord>? dictionaryBox;

  Future<void> openBox() async {
    dictionaryBox = Hive.box<DictionaryWord>('dictionaryBox');
  }

  Future<void> _ensureBoxInitialized() async {
    if (dictionaryBox == null) {
      await openBox();
    }
  }

  Future<List<DictionaryWord>> loadCsvData() async {
    final csvFile = await rootBundle.loadString('assets/dictionary.csv');
    final csvData = CsvToListConverter().convert(csvFile, eol: '\n');

    if (csvData.isEmpty) {
      throw Exception('CSV file is empty.');
    }
    final List<DictionaryWord> parsedData = [];


    for (int i = 0; i < csvData.length; i++) {
      final row = csvData[i];
      int? parsedId = int.tryParse(row[0].toString());
      if (row.length != 4) {
        print('Invalid rows----: $row');
        continue;
      }
      parsedData.add(DictionaryWord(
        id: parsedId ?? 0,
        word: row[1].toString(),
        partOfSpeech: row[2].toString(),
        meaning: row[3].toString(),
      ));
    }

    return parsedData;
  }
  

  Future<void> saveDataToHive(List<DictionaryWord> csvData) async {
    await _ensureBoxInitialized();
    await dictionaryBox!.clear();
   
    for (var word in csvData) {
      await dictionaryBox!.put(word.id, word);
    }
  }


  List<DictionaryWord> retrieveDataFromHive() {
    if (dictionaryBox == null) {
      throw Exception('Hive box is not initialized. Call openBox() first.');
    }
    return dictionaryBox!.values.toList();
  }

  Future<void> loadAndSaveCsvData() async {
    try {
      final csvData = await loadCsvData();
      await saveDataToHive(csvData);
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }
}

