import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartexpencemanager/services/firestore_database.dart';

class KeepNotesScreen extends StatelessWidget {
  const KeepNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreDb = FirebaseFirestoreDb();
    return Scaffold(
      appBar: AppBar(
        title: Text('Keep Notes'),
        automaticallyImplyLeading: false,
      ),
      body: NotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          firestoreDb.addNote();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  final FirebaseFirestoreDb firestoreDb = FirebaseFirestoreDb();

  NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestoreDb.getNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notes = snapshot.data?.docs ?? [];

        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index].data();
            return ListTile(
              title: Text(note['title'] ?? ''),
              subtitle: Text(note['content'] ?? ''),
              trailing: Text(
                note['tags']?.join(', ') ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}
