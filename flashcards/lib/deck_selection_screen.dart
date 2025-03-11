import 'package:flutter/material.dart';
import 'add_flashcard_screen.dart';
import 'flashcard_screen.dart';
import 'package:provider/provider.dart';
import 'deck_state.dart';

class DeckSelectionScreen extends StatelessWidget {
  const DeckSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deckState = Provider.of<DeckState>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFlashcardScreen(
              decks: deckState.decks,
              onFlashcardAdd: (card, deckTitle) =>
                  deckState.addCardToDeck(card, deckTitle),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text("Choose a deck")),
      body: ListView.builder(
        itemCount: deckState.decks.length,
        itemBuilder: (context, index) {
          final deck = deckState.decks[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(deck.title),
              subtitle: Text('${deck.cards.length} cards'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardScreen(deck: deck),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}