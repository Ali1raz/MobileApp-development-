import 'package:flutter_riverpod/flutter_riverpod.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  bool isAnswered;
  bool isCorrect;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.isAnswered = false,
    this.isCorrect = false
  });
}

class Deck {
  final String id;
  final String name;
  final List<Flashcard> cards;
  int correctCount;

  Deck({
    required this.id,
    required this.name,
    required this.cards,
    this.correctCount = 0
  });

  final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Deck>>((ref) {
    return FlashcardNotifier();
  });
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Deck>>((ref) {
  return FlashcardNotifier();
});

class FlashcardNotifier extends StateNotifier<List<Deck>> {
  FlashcardNotifier(): super([
    Deck(id: "1", name: "Flutter Basics", cards: []),
    Deck(id: "2", name: "Dart Fundamentals", cards: []),
  ]);

  Deck? _currentDeck;
  Deck? get currentDeck => _currentDeck;

  void setCurrentDeck(Deck deck) {
    _currentDeck = deck;
  }

  void addFlashcard(Flashcard flashcard) {
    _currentDeck?.cards.add(flashcard);
    state = [...state]; // notify listeners by updating the state
  }

  void resetCard(int index) {
    if (_currentDeck == null || index < 0 || index >= _currentDeck!.cards.length) return;
    final card = _currentDeck!.cards[index];
    if (card.isAnswered) {
      if (card.isCorrect) {
        _currentDeck?.correctCount--;
      } else {
        _currentDeck?.correctCount++;
      }
      card.isAnswered = false;
      card.isCorrect = false;
      // print("answered true");
      state = [...state];
    }
  }

  void updateScore(int cardIndex, bool isCorrect) {
    if (_currentDeck == null) return;
    final card = _currentDeck!.cards[cardIndex];
    if (!card.isAnswered) {
      card.isCorrect = isCorrect;
      if (isCorrect) {
        _currentDeck?.correctCount++;
      } else {
        _currentDeck?.correctCount--;
      }
      card.isAnswered = true;
      state = [...state];
    }
  }
}