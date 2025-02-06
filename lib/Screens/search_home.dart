import 'package:dictionary_project/Screens/search_history_page.dart';
import 'package:dictionary_project/Service/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:dictionary_project/HiveModel/dictionary_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _engmalcontroller = TextEditingController();
  final HiveService _hiveService = HiveService();
  bool isLoading = true;
  List<DictionaryWord> allData = [];
  List<DictionaryWord> searchFilter = [];
  int isStartColor = 1;
  List<String> searchHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    await _hiveService.openBox();
    List<DictionaryWord> rawData = _hiveService.retrieveDataFromHive();

    // Step 1: Group words to avoid duplicates
    List<DictionaryWord> groupedData = _groupWordsWithMeanings(rawData);

    // Step 2: Sort words alphabetically
    groupedData.sort((a, b) => a.word.compareTo(b.word));

    setState(() {
      isLoading = false;
      allData = groupedData;
      searchFilter = groupedData; // Ensure search results are also sorted
    });
  }

  void filterSearch(String value, String filterType) {
    final searchQuery = value.toLowerCase().trim();
    if (searchQuery.isEmpty) {
      setState(() {
        searchFilter = _groupWordsWithMeanings(allData);
      });
    } else {
      final filteredData = allData.where((element) {
        final word = element.word.toLowerCase().trim();
        if (filterType == 'start') {
          return word.startsWith(searchQuery);
        } else if (filterType == 'contains') {
          return word.contains(searchQuery);
        } else if (filterType == 'end') {
          return word.endsWith(searchQuery);
        }
        return false;
      }).toList();

      setState(() {
        searchFilter = _groupWordsWithMeanings(filteredData)
          ..sort((a, b) => a.word.compareTo(b.word)); // Sort alphabetically
      });
    }
  }

  /// Groups words and combines their meanings into a single entry
  List<DictionaryWord> _groupWordsWithMeanings(List<DictionaryWord> data) {
    final Map<String, Set<String>> groupedMap = {};

    for (var item in data) {
      final word = item.word.trim().toLowerCase(); // Normalize words
      if (groupedMap.containsKey(word)) {
        groupedMap[word]!.add(item.meaning.trim());
      } else {
        groupedMap[word] = {item.meaning.trim()};
      }
    }

    // Convert back to a sorted list of DictionaryWord objects
    return groupedMap.entries.map((entry) {
      return DictionaryWord(
        id: entry.key.hashCode,
        word: entry.key,
        partOfSpeech: entry.key, // Keep part of speech if needed
        meaning: entry.value.join(", "), // Join meanings into a string
      );
    }).toList()
      ..sort((a, b) => a.word.compareTo(b.word)); // Sort words alphabetically
  }

  void searchDictionary(String value, String filterType) {
    final searchQuery = value.trim();
    if (value.trim().isNotEmpty) {
      setState(() {
        if (!searchHistory.contains(searchQuery)) {
          searchHistory.add(searchQuery);
          print(searchHistory); 
        }
      });
    }
    filterSearch(value, filterType);
  }

  @override
  void dispose() {
    _engmalcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Dictionary Search',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 80,
                  color: Colors.blue.shade800,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchHistoryPage(
                                    historys: searchHistory,
                                  ),
                                ));
                          },
                          icon: Icon(Icons.history, color: Colors.white)),
                      Expanded(
                        child: TextField(
                          controller: _engmalcontroller,
                          onChanged: (String value) {
                            filterSearch(value,
                                'start'); // You can pass the correct filter function here
                          },
                          onSubmitted: (String value) {
                            // This function will handle saving the exact word when the user submits the search
                            searchDictionary(value, 'start');
                          },
                          decoration: InputDecoration(
                            hintText: 'Search English Word',
                            hintStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchFilter.length,
                    itemBuilder: (context, index) {
                      final item = searchFilter[index];
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final uniqueMeanings = item.meaning
                                  .split(", ")
                                  .map((e) => e.trim()) // Trim extra spaces
                                  .toSet()
                                  .toList(); // Ensure uniqueness

                              return Dialog(
                                child: Container(
                                  height: 300,
                                  width: 300,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.word,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView(
                                          children: uniqueMeanings
                                              .map((meaning) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text("- $meaning"),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: ListTile(
                          title: Text(item.word),
                          // subtitle: Text(item.meaning),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildFilterButton('Start', 1, 'start'),
                          buildFilterButton('Contains', 2, 'contains'),
                          buildFilterButton('End', 3, 'end'),
                        ],
                      )),
                )
              ],
            ),
    );
  }

  Widget buildFilterButton(String text, int index, String filterType) {
    return InkWell(
      onTap: () {
        setState(() {
          isStartColor = index;
        });
        print("$text button tapped---");
        searchDictionary(_engmalcontroller.text, filterType);
      },
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: isStartColor == index ? Colors.blue.shade800 : Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
