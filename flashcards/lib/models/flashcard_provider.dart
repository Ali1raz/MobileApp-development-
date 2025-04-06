import 'package:flashcards/database/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Flashcard {
  final String id;
  late final String question;
  late final String answer;
  bool isAnswered;
  bool isCorrect;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.isAnswered = false,
    this.isCorrect = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'answer': answer,
    'isAnswered': isAnswered ? 1 : 0,
    'isCorrect': isCorrect ? 1 : 0,
  };

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
    id: map['id'],
    question: map['question'],
    answer: map['answer'],
    isAnswered: map['isAnswered'] == 1,
    isCorrect: map['isCorrect'] == 1,
  );

  // In Flashcard class (flashcard_provider.dart)
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class Deck {
  final String id;
  late final String name;
  List<Flashcard> cards;
  int correctCount;

  Deck({
    required this.id,
    required this.name,
    required this.cards,
    this.correctCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'correctCount': correctCount,
  };

  factory Deck.fromMap(Map<String, dynamic> map) => Deck(
    id: map['id'],
    name: map['name'],
    cards: [],
    correctCount: map['correctCount'],
  );

  Deck copyWith({
    String? id,
    String? name,
    List<Flashcard>? cards,
    int? correctCount,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      cards: cards ?? List.from(this.cards),
      correctCount: (correctCount ?? this.correctCount).clamp(0, this.cards.length),
    );
  }
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, List<Deck>>((
  ref,
) {
  return FlashcardNotifier();
});

class FlashcardNotifier extends StateNotifier<List<Deck>> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String? currentDeckId;

  FlashcardNotifier() : super([]) {
    _initializeDefaultDecks();
  }

  Deck? get currentDeck {
    return state.firstWhere(
          (deck) => deck.id == currentDeckId,
      orElse: () => state.isNotEmpty ? state[0] : Deck(id: '', name: '', cards: []),
    );
  }

  void setCurrentDeck(Deck deck) {
    currentDeckId = deck.id;
  }

  Future<void> addDeck(Deck newDeck) async {
    await _dbHelper.insertDeck(newDeck);
    await loadDecks();
  }

  Future<void> deleteDeck(Deck deck) async {
    await _dbHelper.deleteDeck(deck.id);
    await loadDecks();
  }

  Future<void> updateDeckName(Deck oldDeck, String newName) async {
    // Create new deck instance with updated name
    final updatedDeck = Deck(
      id: oldDeck.id,
      name: newName,
      cards: oldDeck.cards,
      correctCount: oldDeck.correctCount,
    );
    await _dbHelper.updateDeck(updatedDeck);
    await loadDecks();
  }

  void updateScore(int cardIndex, bool isCorrect) async {
    if (currentDeckId == null) return;

    final deckIndex = state.indexWhere((deck) => deck.id == currentDeckId);
    if (deckIndex == -1) return;

    final currentDeck = state[deckIndex];
    if (cardIndex >= currentDeck.cards.length) return;

    // Immutable copies
    final newCards = List<Flashcard>.from(currentDeck.cards);
    final card = newCards[cardIndex];

    if (card.isAnswered) return;

    // Calculate score change
    int scoreDelta = 0;
    if (isCorrect) scoreDelta = 1;
    if (card.isCorrect) scoreDelta = -1; // Undo previous correct status

    final newCorrectCount = (currentDeck.correctCount + scoreDelta).clamp(0, currentDeck.cards.length);

    // Update card
    final updatedCard = card.copyWith(
      isAnswered: true,
      isCorrect: isCorrect,
    );

    newCards[cardIndex] = updatedCard;

    // Update deck
    final updatedDeck = currentDeck.copyWith(
      cards: newCards,
      correctCount: newCorrectCount,
    );

    // Persist changes
    await _dbHelper.updateCard(updatedCard);
    await _dbHelper.updateDeck(updatedDeck);

    // Update state
    final newState = List<Deck>.from(state);
    newState[deckIndex] = updatedDeck;
    state = newState;
  }

  Future<void> resetCard(int cardIndex) async {
    if (currentDeckId == null) return;

    final deckIndex = state.indexWhere((deck) => deck.id == currentDeckId);
    if (deckIndex == -1) return;

    final currentDeck = state[deckIndex];
    final newCards = List<Flashcard>.from(currentDeck.cards);
    final card = newCards[cardIndex];

    // Calculate score change
    final scoreDelta = card.isCorrect ? -1 : 0;
    final newCorrectCount = (currentDeck.correctCount + scoreDelta).clamp(0, currentDeck.cards.length);

    // Update card
    final updatedCard = card.copyWith(
      isAnswered: false,
      isCorrect: false,
    );

    newCards[cardIndex] = updatedCard;

    // Update deck
    final updatedDeck = currentDeck.copyWith(
      cards: newCards,
      correctCount: newCorrectCount,
    );

    // Persist changes
    await _dbHelper.updateCard(updatedCard);
    await _dbHelper.updateDeck(updatedDeck);

    // Update state
    final newState = List<Deck>.from(state);
    newState[deckIndex] = updatedDeck;
    state = newState;
  }

  Future<void> _initializeDefaultDecks() async {
    await loadDecks();

    if (state.isEmpty) {
      final defaultDecks = [
        Deck(id: DateTime.now().toString(), name: "Flutter Basics", cards: []),
        Deck(
          id: DateTime.now().toString(),
          name: "Dart Fundamentals",
          cards: [],
        ),
      ];

      for (final deck in defaultDecks) {
        await _dbHelper.insertDeck(deck);
      }

      await loadDecks();
    }
  }

  Deck? _currentDeck;

  Future<void> loadDecks() async {
    final decks = await _dbHelper.getAllDecks();

    for (final deck in decks) {
      final cards = await _dbHelper.getCardsForDeck(deck.id);
      deck.cards = cards;
    }
    state = decks;
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    if (currentDeckId == null) return;

    final deckIndex = state.indexWhere((deck) => deck.id == currentDeckId);
    if (deckIndex == -1) return;

    // Create new immutable deck with added card
    final currentDeck = state[deckIndex];
    final newCards = List<Flashcard>.from(currentDeck.cards)..add(flashcard);

    final updatedDeck = currentDeck.copyWith(
      cards: newCards,
      correctCount: currentDeck.correctCount,
    );

    // Update database FIRST
    await _dbHelper.insertCard(flashcard, currentDeckId!);

    // Create new state
    final newState = List<Deck>.from(state);
    newState[deckIndex] = updatedDeck;
    state = newState;
  }

  Future<void> deleteCard(int cardIndex) async {
    if (currentDeckId == null) return;
    final deckIndex = state.indexWhere((deck) => deck.id == currentDeckId);
    if (deckIndex == -1) return;

    final currentDeck = state[deckIndex];
    if (cardIndex >= currentDeck.cards.length) return;

    final card = currentDeck.cards[cardIndex];
    if (card.isCorrect) currentDeck.correctCount--;

    await _dbHelper.deleteCard(card.id);

    // Create new immutable state
    final newCards = List<Flashcard>.from(currentDeck.cards)..removeAt(cardIndex);
    final updatedDeck = currentDeck.copyWith(
      cards: newCards,
      correctCount: currentDeck.correctCount,
    );

    final newState = List<Deck>.from(state);
    newState[deckIndex] = updatedDeck;
    state = newState;

    await _dbHelper.updateDeck(updatedDeck);
  }

  Future<void> updateCardQuestionAnswer(
    int cardIndex,
    String newQuestion,
    String newAnswer,
  ) async {
    if (_currentDeck == null) return;
    final card = _currentDeck!.cards[cardIndex];

    card.question = newQuestion;
    card.answer = newAnswer;

    await _dbHelper.updateCardQuestionAnswer(card);
    state = [...state];
  }
}
