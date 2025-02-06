import 'package:dictionary_project/HiveModel/dictionary_model.dart';
import 'package:dictionary_project/Screens/bottom_navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(DictionaryWordAdapter());

  // await Hive.openBox<DictionaryWord>('DictionaryWordAdapter');
  await Hive.openBox<DictionaryWord>('dictionaryBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const BottomNvagationBar(),
      home: BottomNvagationBar(),
    );
  }
}
