import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list_hive/screens/add_update_note.dart';
import 'package:todo_list_hive/widgets/card.dart';
import '../hive/boxes.dart';
import '../model/note.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TODO List | Hive'),
      ),
      body: ValueListenableBuilder<Box<Note>>(
        valueListenable: Boxes.getNotes().listenable(),
        builder: (context, box, _) {
          notes = box.values.toList().cast<Note>();
          return buildContent(notes);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AddUpdateNote(
                noteKey: -1,
              )),
    );
  }

  @override
  void dispose() {
    Hive.box('notes').close();
    super.dispose();
  }

  Widget buildContent(List<Note> notes) {
    if (notes.isEmpty) {
      return const Center(
        child: Text(
          "No notes yet!",
          style: TextStyle(fontSize: 24, color: Colors.green),
        ),
      );
    }
    return buildNotes(notes);
  }

  Widget buildNotes(List<Note> notes) {
    double height = MediaQuery.of(context).size.height;

    return ListView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(top: height * 0.013),
        itemCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          final note = notes[index];
          return Dismissible(
              background: slideLeftBackground(),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {
                  _onDelete(note.key);
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text('${note.title} removed')));
              },
              key: Key(UniqueKey().toString()),
              child: buildNote(context, note));
        });
  }

  Widget buildNote(BuildContext context, Note note) {
    double height = MediaQuery.of(context).size.height;

    final String title = note.title;
    final String description = note.description;
    final DateTime created = note.created;
    final Color color = Color(note.color);

    return Column(
      children: [
        CardWidget(
            title: title,
            description: description,
            created: created,
            color: color,
            noteKey: note.key),
        SizedBox(
          height: height * 0.013,
        )
      ],
    );
  }

  Widget slideLeftBackground() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(
          bottom: height * 0.01, left: height * 0.01, right: height * 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.025),
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.delete,
            color: Colors.white,
          ),
          const Text(
            "Delete",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: width * 0.05,
          ),
        ],
      ),
    );
  }

  void _onDelete(int index) {
    final box = Boxes.getNotes();
    box.delete(index);
  }
}
