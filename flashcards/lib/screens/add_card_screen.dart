import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FlashcardProvider>(context);

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
                    provider.addFlashcard(
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