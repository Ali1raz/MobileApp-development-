import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_provider.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Card"),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: "Answer"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a Answer";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref.read(flashcardProvider.notifier).addFlashcard(
                      Flashcard(
                          id: DateTime.now().toString(),
                          question: _questionController.text,
                          answer: _answerController.text
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text("Save FlashCard"),
              )
            ],
          ),
        ),
      ),
    );
  }
}