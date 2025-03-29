import 'package:flashcards/database/database_helper.dart';
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'answer': answer,
    'isAnswered': isAnswered ? 1 : 0,
    'isCorrect': isCorrect ? 1: 0
  };

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
    id: map['id'],
    question: map['question'],
    answer: map['answer'],
    isAnswered: map['isAnswered'] == 1,
    isCorrect: map['isCorrect'] == 1
  );
}

class Deck {
  final String id;
  final String name;
  List<Flashcard> cards;
  int correctCount;

  Deck({
    required this.id,
    required this.name,
    required this.cards,
    this.correctCount = 0
  });
  
  Map<String, dynamic> toMap()=> {
    'id': id,
    'name': name,
    'correctCount': correctCount
  };
  
  factory Deck.fromMap(Map<String, dynamic> map) => Deck(
    id: map['id'],
    name: map['name'],
    cards: [], // loaded separately
    correctCount: map['correctCount']
  );

  final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Deck>>((ref) {
    return FlashcardNotifier();
  });
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Deck>>((ref) {
  return FlashcardNotifier();
});

class FlashcardNotifier extends StateNotifier<List<Deck>> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  FlashcardNotifier() : super([]) {
    _initializeDefaultDecks();
  }

  Future<void> _initializeDefaultDecks() async {
    // Load existing decks
    await loadDecks();

    // If no decks exist, create default ones
    if (state.isEmpty) {
      final defaultDecks = [
        Deck(id: DateTime.now().toString(), name: "Flutter Basics", cards: []),
        Deck(id: DateTime.now().toString(), name: "Dart Fundamentals", cards: []),
      ];

      for (final deck in defaultDecks) {
        await _dbHelper.insertDeck(deck);
      }

      // Reload decks after creating defaults
      await loadDecks();
    }
  }
  
  Deck? _currentDeck;
  Deck? get currentDeck => _currentDeck;
  
  Future<void> loadDecks() async {
    final decks = await _dbHelper.getAllDecks();
    
    for (final deck in decks) {
      final cards = await _dbHelper.getCardsForDeck(deck.id);
      deck.cards = cards;
    }
    state = decks;
  }

  void setCurrentDeck(Deck deck) {
    _currentDeck = deck;
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    if (_currentDeck == null) return;
    await _dbHelper.insertCard(flashcard, _currentDeck!.id);
    _currentDeck!.cards.add(flashcard);
    state = [...state]; // notify listeners by updating the state
  }

  Future<void> resetCard(int cardIndex) async {
    if (_currentDeck == null) return;
    final card = _currentDeck!.cards[cardIndex];

    card.isAnswered = false;
    _currentDeck!.correctCount -= card.isCorrect ? 1 : -1;
    card.isCorrect = false;

    await _dbHelper.updateCard(card);
    state = [...state];
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