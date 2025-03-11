import 'package:flutter/material.dart';
import 'deck.dart';
import 'flashcard.dart';

class DeckState with ChangeNotifier {
  List<Deck> decks = [
    Deck(
        title: "Flutter Basics",
        cards: [
          Flashcard(question: "What is Flutter?", answer: "Google UI toolkit"),
          Flashcard(question: "Flutter language?", answer: "Dart"),
        ]
    ),
    Deck(
        title: "Dart",
        cards: [
          Flashcard(question: "Null safety?", answer: "Prevents null errors"),
        ]
    )
  ];

  void addCardToDeck(Flashcard card, String deckTitle) {
    final deck = decks.firstWhere(
          (d) => d.title == deckTitle,
      orElse: () => throw Exception("Deck not found"),
    );
    deck.cards.add(card);
    notifyListeners();
  }
}