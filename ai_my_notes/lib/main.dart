import 'package:flutter/material.dart';
import 'src/data/database_helper.dart';
import 'src/ui/note_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ai-MyNotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: NoteListScreen(databaseHelper: DatabaseHelper.instance),
    );
  }
}
