import 'package:dictionary_project/HiveModel/dictionary_model.dart';
import 'package:dictionary_project/Screens/malayalm_home_page.dart';
import 'package:dictionary_project/Screens/search_history_page.dart';
import 'package:dictionary_project/Service/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _engmalcontroller = TextEditingController();
  final HiveService _hiveService = HiveService();
  int isStartColor = 1;
  bool isLoading = true;
  List<DictionaryWord> allData = [];
  List<DictionaryWord> searchFilter = [];
  List<String> searchHistory = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initaliseHive();
  }

  Future<void> _initaliseHive() async {
    await _hiveService.openBox();
    List<DictionaryWord> rawData = _hiveService.retrieveDataFromHive();
    List<DictionaryWord> groupedData = _groupWordsWithMeanings(rawData);
    groupedData.sort((a, b) => a.word.compareTo(b.word));
    setState(() {
      isLoading = false;
      allData = groupedData;
      searchFilter = groupedData;
    });
  }

  void filterSearch(String value, String filterType) {
    final searchQuery = value.toLowerCase().trim();
    if (searchQuery.isEmpty) {
      setState(() {
        searchFilter = _groupWordsWithMeanings(
            allData); // Show all data when search is empty
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
        return false; // Default case
      }).toList();

      setState(() {
        searchFilter = _groupWordsWithMeanings(filteredData)
          ..sort((a, b) => a.word.compareTo(b.word)); // Sort alphabetically
      });
    }
  }

  List<DictionaryWord> _groupWordsWithMeanings(List<DictionaryWord> data) {
    final Map<String, Set<String>> groupedMap = {};

    for (var item in data) {
      final word = item.word.trim().toLowerCase();
      if (groupedMap.containsKey(word)) {
        groupedMap[word]!.add(item.meaning.trim());
      } else {
        groupedMap[word] = {item.meaning.trim()};
      }
    }

    return groupedMap.entries.map((entry) {
      return DictionaryWord(
        id: entry.key.hashCode,
        word: entry.key,
        partOfSpeech: entry.key, 
        meaning: entry.value.join(", "), 
      );
    }).toList()
      ..sort((a, b) => a.word.compareTo(b.word));
  }

  void searchDictionary(String value, String filterType) {
    final searchQuery = value.toLowerCase().trim();
    filterSearch(value, filterType);
    if (value.trim().isNotEmpty) {
      setState(() {
        if (!searchHistory.contains(searchQuery)) {
          searchHistory.add(searchQuery);
          print(searchHistory);
        }
      });
    }
  }

  @override
  void dispose() {
    _engmalcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        //  WillPopScope(
        //   onWillPop: () async {
        //     bool exitApp = await _showExitDialog();
        //     return exitApp; // If true, exit; if false, stay in the app
        //   },
        //   child:
        Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade800,
        title: const Text('Malayalam Dictionary',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Share.share(
                  'Check out this cool Flutter app: https://flutter.dev');
              print("Share dialog opened");
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              color: Colors.white,
            ),
            Container(
              width: double.infinity,
              height: 80,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'English <-> Malayalam Dictionary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Tools'),
            ),
            ListTile(
              title: Text('Poems'),
            ),
            ListTile(
              title: Text('Proverbs'),
            ),
            ListTile(
              title: Text('Riddles'),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // color: Colors.green,
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue.shade800,
                          ),
                          child: const Center(
                            child: Text(
                              'ENG>MAL',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const MalayalmHomePage();
                            }));
                            print("Button tapped");
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.grey.shade500,
                            ),
                            child: const Center(
                              child: Text(
                                'MAL>ENG',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade500,
                    thickness: 1.5,
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
                                    .map((e) => e.trim()) 
                                    .toSet()
                                    .toList(); 

                                return Dialog(
                                  child: Container(
                                    height: 300,
                                    width: 300,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            item.word,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
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
                  Container(
                      height: 58,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade800,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchHistoryPage(
                                            historys: searchHistory),
                                      ));
                                },
                                icon: Icon(
                                  Icons.history,
                                  color: Colors.black,
                                  size: 25,
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                              ),
                              child: TextField(
                                controller: _engmalcontroller,
                                onChanged: (value) {
                                  filterSearch(value, 'start');
                                },
                                onSubmitted: (String value) {
                                  
                                  searchDictionary(value, 'start');
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blue.shade800),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  hintText: 'Type English Word',
                                  hintStyle: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  searchDictionary(
                                      _engmalcontroller.text, 'start');
                                },
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 25,
                                )),
                          ])),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
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

  // Future<bool> _showExitDialog() async {
  //   return await showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => AlertDialog(
  //           title: const Text("Exit App"),
  //           content: const Text("Are you sure you want to exit?"),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: const Text(""),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               child: const Text("Yes"),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false; // If dismissed, return false
}
