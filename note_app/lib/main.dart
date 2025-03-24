import 'package:flutter/material.dart';
import 'package:note_app/db_helper.dart';
import 'package:note_app/note.dart';
import 'package:note_app/note_editor.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: NoteScreen(),
    );
  }
}

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  void fetchNotes() async {
    final notesData = await dbHelper.getNotes();
    debugPrint("fetch");
    setState(() {
      notes = notesData.map((note) => Note.fromMap(note)).toList();
    });
  }

  void addNewNote() async {
    try {
      final newNote = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteEditor()),
      );
      if (newNote != null) {
        await dbHelper.addNote(newNote);
        fetchNotes();
      }
    } catch (e) {
      debugPrint("Error adding note: $e");
    }
  }

  void deleteNote(int id) async {
    try {
      await dbHelper.deleteNote(id);
      fetchNotes();
    } catch (e) {
      debugPrint("Error deleting note: $e");
      // Consider adding a SnackBar ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      body:
          notes.isEmpty
              ? Center(child: Text("No Notes"))
              : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      child: Icon(Icons.do_not_disturb_on_total_silence_outlined),
                    ),
                    trailing: IconButton(
                      onPressed: () => deleteNote(note.id!),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
