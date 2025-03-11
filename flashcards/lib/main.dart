import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'deck_selection_screen.dart';
import 'deck_state.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => DeckState(),
    child: const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FlashCards App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const DeckSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}