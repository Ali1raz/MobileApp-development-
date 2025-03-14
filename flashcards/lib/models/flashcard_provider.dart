import 'package:flutter/cupertino.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  bool isAnswered;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.isAnswered = false
  });
}

class Deck {
  final String id;
  final String name;
  final List<Flashcard> cards;
  int correctCount;

  Deck({required this.id, required this.name, required this.cards, this.correctCount = 0});
}

class FlashcardProvider with ChangeNotifier {
  final List<Deck> _decks = [
    Deck(id: "1", name: "Flutter Basics", cards: []),
    Deck(id: "2", name: "Dart Fundamentals", cards: []),
  ];

  List<Deck> get decks => _decks;

  Deck? _currentDeck;
  Deck? get currentDeck => _currentDeck;

  void setCurrentDeck(Deck deck) {
    _currentDeck = deck;
    notifyListeners();
  }

  void addFlashcard(Flashcard flashcard) {
    _currentDeck?.cards.add(flashcard);
    notifyListeners();
  }

  void resetCard(int index) {
    if (_currentDeck == null || index < 0 || index >= _currentDeck!.cards.length) return;
    final card = _currentDeck!.cards[index];
    if (card.isAnswered) {
      card.isAnswered = false;
      if (_currentDeck!.correctCount > 0) {
        _currentDeck?.correctCount--;
      }
      notifyListeners();
    }
  }

  void updateScore(int cardIndex, bool isCorrect) {
    if (_currentDeck == null) return;
    final card = _currentDeck!.cards[cardIndex];
    if (!card.isAnswered) {
      if (isCorrect) {
        _currentDeck?.correctCount++;
      } else {
        _currentDeck?.correctCount;
      }
      card.isAnswered = true;
      notifyListeners();
    }
  }
}