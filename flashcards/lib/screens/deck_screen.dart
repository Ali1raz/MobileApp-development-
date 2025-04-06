import 'package:flutter/material.dart';
import '../models/flashcard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_card_screen.dart';

class DeckScreen extends ConsumerStatefulWidget {
  const DeckScreen({super.key});

  @override
  ConsumerState<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends ConsumerState<DeckScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _isFront = true;

  @override
  Widget build(BuildContext context) {
    final deck = ref
        .watch(flashcardProvider)
        .firstWhere(
          (deck) =>
              deck.id == ref.read(flashcardProvider.notifier).currentDeck?.id,
        );

    if (deck.cards.isNotEmpty) {
      _currentPage = _currentPage.clamp(0, deck.cards.length - 1);
    } else {
      _currentPage = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/add-card'),
            child: const Text("Add Card"),
          ),
          if (deck.cards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditCardScreen(
                            card: deck.cards[_currentPage],
                            cardIndex: _currentPage,
                          ),
                    ),
                  ),
            ),
        ],
      ),
      body:
          deck.cards.isEmpty
              ? const Center(child: Text("No cards in this deck"))
              : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Answered?: ${deck.cards[_currentPage].isAnswered}"),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: deck.cards.length,
                      onPageChanged:
                          (index) => setState(() {
                            _currentPage = index;
                            _isFront = true;
                          }),
                      itemBuilder: (context, index) {
                        final card = deck.cards[index];

                        return GestureDetector(
                          onTap: () => setState(() => _isFront = !_isFront),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 50),
                            child:
                                _isFront
                                    ? _buildCardSide(
                                      card.question,
                                      Colors.blue,
                                      card,
                                    )
                                    : _buildCardSide(
                                      card.answer,
                                      Colors.green,
                                      card,
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed:
                              deck.cards[_currentPage].isAnswered
                                  ? null
                                  : () {
                                    ref
                                        .read(flashcardProvider.notifier)
                                        .updateScore(_currentPage, false);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Incorrect",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              deck.cards[_currentPage].isAnswered
                                  ? null
                                  : () {
                                    ref
                                        .read(flashcardProvider.notifier)
                                        .updateScore(_currentPage, true);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Correct",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              deck.cards[_currentPage].isAnswered
                                  ? () {
                                    ref
                                        .read(flashcardProvider.notifier)
                                        .resetCard(_currentPage);
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text("Reset Card"),
                        ),
                      ],
                    ),
                  ),
                  Text("Score: ${deck.correctCount}/${deck.cards.length}"),
                ],
              ),
    );
  }

  Widget _buildCardSide(String text, Color color, Flashcard card) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                text,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
        if (card.isAnswered)
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.all(8),
                  child: Text(
                    "Answered: ${card.isCorrect ? "Correct" : "Incorrect"}",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
