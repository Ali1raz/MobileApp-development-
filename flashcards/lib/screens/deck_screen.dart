import 'package:flashcards/models/flashcard_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _isFront = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FlashcardProvider>(context);
    final deck = provider.currentDeck!;
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
                  onPressed: deck.cards[_currentPage].isAnswered ? null : () => provider.updateScore(_currentPage, false),
                  child: Text("Incorrect"),
                ),
                ElevatedButton(
                  onPressed: deck.cards[_currentPage].isAnswered ? null : () => provider.updateScore(_currentPage, true),
                  child: Text("Correct"),
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