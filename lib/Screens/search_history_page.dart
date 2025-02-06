import 'package:flutter/material.dart';

class SearchHistoryPage extends StatefulWidget {
  final List<String> historys;
  const SearchHistoryPage({super.key, required this.historys});

  @override
  // ignore: library_private_types_in_public_api
  _SearchHistoryPageState createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title:
            const Text('Search History', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: widget.historys.isEmpty
          ? const Center(child: Text('No history found.'))
          : ListView.builder(
              itemCount: widget.historys.length,
              itemBuilder: (context, index) {
                final historyItem = widget.historys[index];
                return ListTile(
                  title: Text(historyItem),
                  leading: const Icon(Icons.history),
                );
              },
            ),
    );
  }
}
