import 'package:dictionary_project/HiveModel/dictionary_model.dart';
import 'package:dictionary_project/Service/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MalayalmHomePage extends StatefulWidget {
  const MalayalmHomePage({super.key});

  @override
  _MalayalmHomePageState createState() => _MalayalmHomePageState();
}

class _MalayalmHomePageState extends State<MalayalmHomePage> {
  final TextEditingController _malEngController = TextEditingController();
  final HiveService _hiveService = HiveService();
  int isStartColor = 1;
  bool isLoading = true;
  List<DictionaryWord> allDatas = [];
  List<DictionaryWord> searchMalayalmFilter = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initaliseHive();
  }

  Future<void> _initaliseHive() async {
    await _hiveService.openBox();
    allDatas = _hiveService.retrieveDataFromHive();
    allDatas = _removeDuplicates(allDatas);
    allDatas.sort((a, b) => a.word.compareTo(b.word));
    setState(() {
      isLoading = false;
      searchMalayalmFilter = allDatas;
    });
  }

  List<DictionaryWord> _removeDuplicates(List<DictionaryWord> dataList) {
    var seen = Set<String>();
    return dataList.where((element) {
      if (seen.contains(element.word)) {
        return false;
      } else {
        seen.add(element.word);
        return true;
      }
    }).toList();
  }

  void filterMalayalmSearch(String value, String filterType) {
    final searchQuery = value.toLowerCase().trim();
    if (searchQuery.isEmpty) {
      setState(() {
        searchMalayalmFilter = allDatas;
      });
    } else {
      setState(() {
        searchMalayalmFilter = allDatas.where((element) {
          final meaning = element.meaning.trim();
          if (filterType == 'start') {
            return meaning.startsWith(searchQuery);
          } else if (filterType == 'contains') {
            return meaning.contains(searchQuery);
          } else if (filterType == 'end') {
            return meaning.endsWith(searchQuery);
          }
          return false;
        }).toList();
        searchMalayalmFilter = searchMalayalmFilter.toSet().toList();
      });
    }
  }

  void searchDictionary(String value, String filterType) {
    filterMalayalmSearch(value, filterType);
  }

  @override
  void dispose() {
    _malEngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.red.shade800,
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
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
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
                                'ENG > MAL',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print("Button tapped");
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.red.shade800,
                            ),
                            child: const Center(
                              child: Text(
                                'MAL > ENG',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.5,
                  ),
                  Expanded(
                    child: searchMalayalmFilter.isEmpty
                        ? const Center(
                            child: Text('No data found'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchMalayalmFilter.length,
                            itemBuilder: (context, index) {
                              final items = searchMalayalmFilter[index];

                              return ListTile(
                                title: Text(items.meaning),
                                subtitle: Text(items.word),
                              );
                            }),
                  ),
                  Container(
                    height: 65,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.red.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _malEngController,
                        onChanged: (value) {
                          searchDictionary(value, 'start');
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7)),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  searchDictionary(
                                      _malEngController.text, 'start');
                                },
                                icon: Icon(Icons.search, color: Colors.white)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade800,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red.shade800,
                            ),
                          ),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildFilterMalayalmButton('Start', 1, 'start'),
                              buildFilterMalayalmButton(
                                  'Contains', 2, 'contains'),
                              buildFilterMalayalmButton('End', 3, 'end'),
                            ])),
                  )
                ],
              ),
            ),
    );
  }

  Widget buildFilterMalayalmButton(String text, int index, String filterType) {
    return InkWell(
      onTap: () {
        setState(() {
          isStartColor = index;
        });
        print("$text button tapped---");
        searchDictionary(_malEngController.text, filterType);
      },
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: isStartColor == index ? Colors.red.shade800 : Colors.grey,
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
