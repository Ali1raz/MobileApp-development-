import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(flashcardProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("Select a deck"),
        actions: [
          IconButton(
              icon: Icon(
                ref.watch(themeProvider).brightness == Brightness.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined
              ),
            onPressed: () => themeNotifier.toggleTheme(),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: decks.length,
        itemBuilder: (context, index) {
          final deck = decks[index];

          return ListTile(
            title: Text(deck.name),
            subtitle: Text('Total Cards: ${deck.cards.length}'),
            trailing: Text('correct: ${deck.correctCount}/${deck.cards.length}'),
            onTap: () {
              ref.read(flashcardProvider.notifier).setCurrentDeck(deck);
              Navigator.pushNamed(context, '/deck');
            },
          );
        },
      ),
    );
  }
}
