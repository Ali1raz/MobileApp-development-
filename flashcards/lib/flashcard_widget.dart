import 'package:flutter/material.dart';
import 'flashcard.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard card;
  final bool showQuestion;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.showQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      },
      child: Card(
        key: ValueKey<bool>(showQuestion),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              showQuestion ? card.question : card.answer,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}