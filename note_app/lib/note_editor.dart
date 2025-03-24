import 'package:flutter/material.dart';
import 'note.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      Navigator.pop(context, Note(
        title: title,
        content: content,
        date: DateTime.now().toIso8601String(), // ISO format
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: contentController, decoration: InputDecoration(labelText: 'Content')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveNote,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}