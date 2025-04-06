import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/utils/db_helper.dart';
import 'package:note_app/utils/priority.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailsScreen({super.key, this.note});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  Priority _selectedPriority = Priority.low;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isUpdating = true;
      _title.text = widget.note!.title!;
      _description.text = widget.note!.description!;
      _selectedPriority = widget.note!.priority;
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context);
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Note note = Note(
        id: _isUpdating ? widget.note!.id : null,
        title: _title.text,
        description: _description.text,
        date: DateTime.now().toString(),
        priority: _selectedPriority,
      );

      int result;
      if (_isUpdating) {
        result = await _dbHelper.updateNote(note);
      } else {
        result = await _dbHelper.addNote(note);
      }

      if (result != 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Note saved successfully!")));
        moveToLastScreen();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving note!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdating ? "Update Note" : "Add Note"),
        leading: IconButton(
          onPressed: moveToLastScreen,
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 20,
                    decoration: InputDecoration(labelText: "Title"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Input Required";
                      }
                      return null;
                    },
                    controller: _title,
                  ),

                  TextFormField(
                    maxLength: 50,
                    decoration: InputDecoration(labelText: "Description"),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 5) {
                        return "Value must be at least 5 characters";
                      }
                      return null;
                    },
                    controller: _description,
                  ),
                  DropdownButtonFormField(
                    value: _selectedPriority,
                    decoration: InputDecoration(labelText: "Priority"),
                    items:
                        Priority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.title),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPriority = val!;
                      });
                    },
                  ),

                  SizedBox(height: 30),
                  FilledButton(
                    onPressed: _saveNote,
                    child: Text(_isUpdating ? "Update" : "Save"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
