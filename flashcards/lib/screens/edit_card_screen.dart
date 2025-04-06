import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_provider.dart';

class EditCardScreen extends ConsumerStatefulWidget {
  final Flashcard card;
  final int cardIndex;

  const EditCardScreen({
    super.key,
    required this.card,
    required this.cardIndex,
  });

  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  late final _questionController = TextEditingController(text: widget.card.question);
  late final _answerController = TextEditingController(text: widget.card.answer);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Card"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: "Question"),
                validator: (value) => value?.isEmpty ?? true ? "Required" : null,
              ),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: "Answer"),
                validator: (value) => value?.isEmpty ?? true ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ref.read(flashcardProvider.notifier).updateCardQuestionAnswer(
        widget.cardIndex,
        _questionController.text,
        _answerController.text,
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card"),
        content: const Text("Are you sure you want to delete this card?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(flashcardProvider.notifier).deleteCard(widget.cardIndex);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}