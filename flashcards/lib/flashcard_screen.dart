import 'package:flutter/material.dart';
import 'deck.dart';
import 'flashcard_widget.dart';
import 'navigation_controls.dart';

class FlashcardScreen extends StatefulWidget {
  final Deck deck;
  const FlashcardScreen({super.key, required this.deck});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _showQuestion = true;
  int _currentCardIndex = 0;
  int _score = 0;

  void _toggleCard() => setState(() => _showQuestion = !_showQuestion);

  void _nextCard() {
    if (widget.deck.cards.isEmpty) return;
    setState(() {
      _currentCardIndex = (_currentCardIndex + 1) % widget.deck.cards.length;
      _showQuestion = true;
    });
  }

  void _prevCard() {
    if (widget.deck.cards.isEmpty) return;
    setState(() {
      _currentCardIndex = (_currentCardIndex == 0)
          ? widget.deck.cards.length - 1
          : _currentCardIndex - 1;
      _showQuestion = true;
    });
  }

  void _handleAnswer(bool isCorrect) {
    setState(() => _score += isCorrect ? 10 : -5);
    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deck.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: const Center(child: Text("No cards in this deck!")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(child: Text("Score: $_score")),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleCard,
              child: FlashcardWidget(
                card: widget.deck.cards[_currentCardIndex],
                showQuestion: _showQuestion,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _handleAnswer(false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Incorrect"),
                ),
                ElevatedButton(
                  onPressed: () => _handleAnswer(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Correct"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            NavigationControls(onPrev: _prevCard, onNext: _nextCard),
          ],
        ),
      ),
    );
  }
}