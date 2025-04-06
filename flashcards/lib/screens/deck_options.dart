import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_provider.dart';

void showDeckOptionsModal(BuildContext context, Deck deck, WidgetRef ref) {
  final TextEditingController _controller = TextEditingController(
    text: deck.name,
  );

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  // Update the Rename button onPressed handler
                  onPressed: () async {
                    if (_controller.text.isNotEmpty && _controller.text != deck.name) {
                      await ref.read(flashcardProvider.notifier)
                          .updateDeckName(deck, _controller.text);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Rename'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await ref.read(flashcardProvider.notifier).deleteDeck(deck);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
