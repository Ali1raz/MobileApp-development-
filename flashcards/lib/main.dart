import 'package:flashcards/database/database_helper.dart';
import 'package:flashcards/screens/add_deck_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/add_card_screen.dart';
import 'screens/deck_screen.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(
    const ProviderScope(
      child: MyApp(),
    )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashCards App",
      theme: theme,
      initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/deck': (context) => const DeckScreen(),
          '/add-card': (context) => const AddCardScreen(),
          '/add-deck': (context) => const AddDeckScreen(),
        }
    );
  }
}