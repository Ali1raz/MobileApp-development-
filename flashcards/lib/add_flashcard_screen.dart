import 'package:flutter/material.dart';
import 'flashcard.dart';
import 'deck.dart';

class AddFlashcardScreen extends StatefulWidget {
  final List<Deck> decks;
  final Function(Flashcard, String) onFlashcardAdd;

  const AddFlashcardScreen({
    super.key,
    required this.decks,
    required this.onFlashcardAdd
  });

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedDeck;
  String _question = '';
  String _answer = '';

  @override
  void initState() {
    super.initState();
    _selectedDeck = widget.decks.isNotEmpty ? widget.decks.first.title : "Default";
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onFlashcardAdd(
        Flashcard(question: _question.trim(), answer: _answer.trim()),
        _selectedDeck,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new FlashCard"),
        actions: [
          IconButton(onPressed: _submitForm, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDeck,
                items: widget.decks
                    .map((deck) => DropdownMenuItem(
                  value: deck.title,
                  child: Text(deck.title),
                )).toList(),
                onChanged: (value) => setState(() => _selectedDeck = value!),
                decoration: const InputDecoration(
                  labelText: "Select Deck",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.question_mark),
                ),
                validator: (val) => val!.trim().isEmpty ? "Required" : null,
                onChanged: (val) => _question = val,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Answer",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb),
                ),
                validator: (val) => val!.trim().isEmpty ? "Required" : null,
                onChanged: (val) => _answer = val,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}