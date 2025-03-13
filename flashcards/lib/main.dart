import 'models/flashcard_provider.dart';
import 'screens/add_card_screen.dart';
import 'screens/deck_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  runApp(
    ChangeNotifierProvider(
      create: (_) => FlashcardProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashCards App",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: "Lato",
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/deck': (context) => const DeckScreen(),
          '/add-card': (context) => const AddCardScreen(),
        }
    );
  }
}