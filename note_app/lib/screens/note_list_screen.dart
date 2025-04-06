import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/provider/theme-provider.dart';
import 'package:note_app/screens/note_details_screen.dart';
import 'package:note_app/utils/db_helper.dart';
import 'package:provider/provider.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  DatabaseHelper? _dbHelper;
  List<Note>? _noteList;
  int _noteCount = 0;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _updateNoteListView();
  }
  void _updateNoteListView() {
    final Future<List<Note>?> noteListFuture = _dbHelper!.getNoteObjectList();
    noteListFuture.then((noteList) {
      setState(() {
        _noteList = noteList;
        _noteCount = noteList!.length;
      });
    });
  }

  void _deleteNote(BuildContext context, int id) async {
    int result = await _dbHelper!.deleteNote(id);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Note deleted successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
      _updateNoteListView();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting note!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  ListView _getListView() {
    return ListView.builder(
      itemCount: _noteCount,
      itemBuilder: (BuildContext context, int index) {
        return Card(
            color: Theme.of(context).cardColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _noteList![index].priority.color,
              child: Text(
                _noteList![index].priority.title.substring(0, 1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(_noteList![index].title!),
            subtitle: Text(_noteList![index].description!),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.red),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Delete Note"),
                      content: Text(
                        "Are you sure you want to delete this note?",
                      ),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Delete"),
                          onPressed: () {
                            _deleteNote(context, _noteList![index].id!);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            onLongPress: () {
              _dbHelper!.deleteNote(_noteList![index].id!);
              _updateNoteListView();
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NoteDetailsScreen(note: _noteList![index]),
                ),
              ).then((_) {
                _updateNoteListView();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Notes"),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ]
      ),
      body:
          (_noteList == null || _noteCount == 0)
              ? Center(child: Text("No Notes Available"))
              : _getListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FloatingActionButton onPressed");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteDetailsScreen()),
          ).then((_) {
            _updateNoteListView();
          });
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }
}
