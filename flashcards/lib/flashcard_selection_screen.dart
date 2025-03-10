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
      _currentCardIndex = (_currentCardIndex+1) % widget.deck.cards.length;
      _showQuestion = true;
    });
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      _score += isCorrect ? 10 : -5;
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
            icon: Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleCard,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                child: Container(
                  width: 300,
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Center(
                    child: Text(
                      _showQuestion ? widget.deck.cards[_currentCardIndex].question:
                      widget.deck.cards[_currentCardIndex].answer,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _handleAnswer(false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Incorrect"),
                ),
                ElevatedButton(onPressed: () => _handleAnswer(true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("Correct"))
              ],
            ),
            ElevatedButton(onPressed: _nextCard, child: const Text("Next")),
          ],
        ),
      ),
    );
  }
}
