import 'package:dictionary_project/Screens/dictionary_page.dart';
import 'package:dictionary_project/Screens/hive_test.dart';
import 'package:dictionary_project/Screens/home_page.dart';
import 'package:flutter/material.dart';

class BottomNvagationBar extends StatefulWidget {
  const BottomNvagationBar({super.key});

  @override
  _BottomNvagationBarState createState() => _BottomNvagationBarState();
}

class _BottomNvagationBarState extends State<BottomNvagationBar> {
  int _selectedIndex = 0;
  List<Widget> pages = [
    //  SearchPage(),
    HomePage(),
    HivePage(),
    DictionaryPage(),
    // SearchHistoryPage( )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.blue.shade800,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
      body: pages.elementAt(_selectedIndex),
    );
  }
}
