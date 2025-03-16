import 'package:flutter/material.dart';
import '../models/flashcard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final deck = ref.watch(flashcardProvider).firstWhere(
          (deck) => deck.id == ref.read(flashcardProvider.notifier).currentDeck?.id,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          TextButton(
          onPressed: () => Navigator.pushNamed(context, '/add-card'),
          child: const Text("Add Card"),
          )
        ],
      ),
      body: deck.cards.isEmpty
      ? const Center(child: Text("No cards in this deck"))
      : Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Answered?: ${deck.cards[_currentPage].isAnswered}")
            ],
          ) ,
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: deck.cards.length,
              onPageChanged: (index) => setState(() { _currentPage = index; _isFront = true; }),
              itemBuilder: (context, index) {
                final card = deck.cards[index];

                return GestureDetector(
                  onTap: () => setState(() => _isFront = !_isFront),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 50),
                    child: _isFront
                    ? _buildCardSide(card.question, Colors.blue)
                    : _buildCardSide(card.answer, Colors.green),
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
                  onPressed: deck.cards[_currentPage].isAnswered
                      ? null
                      : () => ref.read(flashcardProvider.notifier).updateScore(_currentPage, false),
                  child: Text("Incorrect"),
                ),
                ElevatedButton(
                  onPressed: deck.cards[_currentPage].isAnswered
                      ? null
                      : () => ref.read(flashcardProvider.notifier).updateScore(_currentPage, true),
                  child: Text("Correct"),
                ),
                ElevatedButton(
                  onPressed: deck.cards[_currentPage].isAnswered
                      ? () => ref.read(flashcardProvider.notifier).resetCard(_currentPage)
                      : null,
                  child: const Text("Reset Card"),
                ),
              ],
            )
          ),
          Text("Score: ${deck.correctCount}/${deck.cards.length}"),
        ],
      ),
    );
  }
}


Widget _buildCardSide(String text, Color color) {
  return Container(
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
      )
  );
}