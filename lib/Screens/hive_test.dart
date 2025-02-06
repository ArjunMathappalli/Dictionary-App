// // import 'package:dictionary_project/Service/hive_service.dart';
import 'package:dictionary_project/HiveModel/dictionary_model.dart';
import 'package:dictionary_project/Service/hive_service.dart';
import 'package:flutter/material.dart';

class HivePage extends StatefulWidget {
  const HivePage({super.key});

  @override
  State<HivePage> createState() => _HivePageState();
}

class _HivePageState extends State<HivePage> {
  final HiveService _hiveService = HiveService();

  late Future<List<DictionaryWord>> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();

    _dataLoadingFuture = _initializeData();
  }

  Future<List<DictionaryWord>> _initializeData() async {
    await _hiveService.openBox();

    List<DictionaryWord> csvData = _hiveService.retrieveDataFromHive();

    if (csvData.isEmpty) {
      await _hiveService.loadAndSaveCsvData();
      csvData = _hiveService.retrieveDataFromHive();
    }

    // Remove duplicates using a Set (ensures only unique words)
    final uniqueWords = <String, DictionaryWord>{};
    for (var word in csvData) {
      uniqueWords[word.word] =
          word; // Overwrite duplicates with last occurrence
    }

    csvData = uniqueWords.values.toList();

    // Sort only after duplicates are removed
    csvData.sort((a, b) => a.word.compareTo(b.word));

    return csvData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary'), centerTitle: true),
      body: FutureBuilder<List<DictionaryWord>>(
        future: _dataLoadingFuture, // Use the future to load and check data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Retrieve data from Hive after loading
            return Center(
              child: Text(
                'Error loading data: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No valid data found in Hive storage.',
                textAlign: TextAlign.center,
              ),
            );
          }
          final csvData = snapshot.data!;

          // Display the list
          return ListView.builder(
            itemCount: csvData.length,
            itemBuilder: (context, index) {
              print('Total words retrieved: ${csvData.length}');

              final wordData = csvData[index];

              return ListTile(
                title: Text(
                  wordData.word,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(wordData.meaning),
                trailing: Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      wordData.partOfSpeech,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              );
            },
          );
        },
      ),
    );
  }
}
