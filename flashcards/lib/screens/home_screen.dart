import 'package:flashcards/models/flashcard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FlashcardProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a deck"),
      ),
      body: ListView.builder(
        itemCount: provider.decks.length,
        itemBuilder: (context, index) {
          final deck = provider.decks[index];
          return ListTile(
            title: Text(deck.name),
            subtitle: Text('Total Cards: ${deck.cards.length}'),
            trailing: Text('correct: ${deck.correctCount}/${deck.cards.length}'),
            onTap: () {
              provider.setCurrentDeck(deck);
              Navigator.pushNamed(context, '/deck');
            },
          );
        },
      ),
    );
  }
}
