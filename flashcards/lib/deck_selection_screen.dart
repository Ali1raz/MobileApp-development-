import 'package:flutter/material.dart';
import './flashcard.dart';
import './deck.dart';
import './flashcard_selection_screen.dart';

class DeckSelectionScreen extends StatelessWidget {
  final List<Deck> decks = [
    Deck(
        title: "Flutter Basics",
        cards: [
          Flashcard(question: "What is Flutter?", answer: "Google UI toolkit for building natively compiled apps"),
          Flashcard(question: "What language does flutter use?", answer: "Dart"),
        ]
    ),
    Deck(
        title: "Dart",
        cards: [
          Flashcard(question: "what is dart mixins?", answer: "way to reuse code across multiple class."),
          Flashcard(question: "what is null safety in dart?", answer: "Feature that prevents null reference exception."),
        ]
    )
  ];

  DeckSelectionScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose a deck")),
      body: ListView.builder(
          itemCount: decks.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(decks[index].title),
                subtitle: Text('${decks[index].cards.length} cards'),
                trailing: Icon(Icons.arrow_forward),
                onTap: ()  {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FlashcardScreen(deck: decks[index])
                      )
                  );
                },
              ),
            );
          }),
    );
  }
}