import 'package:flutter/material.dart';
import './deck.dart';

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

  void _toggleCard() {
    setState(() {
      _showQuestion = !_showQuestion;
    });
  }

  void _nextCard() {
    setState(() {
      _currentCardIndex = (_currentCardIndex + 1) % widget.deck.cards.length;
      _showQuestion = true;
    });
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        _score += 10;
      } else {
        _score = _score - 5 < 0 ? 0 : _score - 5;
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(child: Text("Score: $_score")),
          )
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleCard,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  width: 300,
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Center(
                    child: Text(
                      _showQuestion
                          ? widget.deck.cards[_currentCardIndex].question
                          : widget.deck.cards[_currentCardIndex].answer,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Show "Correct" and "Incorrect" buttons only if answer is showing.
            if (!_showQuestion)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _handleAnswer(false);
                      _nextCard();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Incorrect"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _handleAnswer(true);
                      _nextCard();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Correct"),
                  ),
                ],
              )
            else
            // When the question is showing, allow the user to tap to reveal the answer.
              ElevatedButton(
                onPressed: _toggleCard,
                child: const Text("Show Answer"),
              ),
          ],
        ),
      ),
    );
  }
}
