import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_provider.dart';

class AddDeckScreen extends ConsumerStatefulWidget {
  const AddDeckScreen({super.key});

  @override
  ConsumerState<AddDeckScreen> createState() => _AddDeckScreenState();
}

class _AddDeckScreenState extends ConsumerState<AddDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Deck")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Deck Name"),
                validator: (value) =>
                value?.isEmpty ?? true ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createDeck,
                child: const Text("Create Deck"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _createDeck() async {
    if (_formKey.currentState!.validate()) {
      final newDeck = Deck(
        id: DateTime.now().toString(),
        name: _nameController.text,
        cards: [],
      );
      await ref.read(flashcardProvider.notifier).addDeck(newDeck);
      Navigator.pop(context);
    }
  }
}