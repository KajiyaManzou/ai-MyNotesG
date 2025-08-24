import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../domain/note.dart';
import 'note_edit_screen.dart';

class NoteListScreen extends StatefulWidget {
  final DatabaseHelper databaseHelper;

  const NoteListScreen({super.key, required this.databaseHelper});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = widget.databaseHelper.readAll();
    });
  }

  Future<void> _navigateAndRefresh(BuildContext context, {Note? note}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          note: note,
          databaseHelper: widget.databaseHelper,
        ),
      ),
    );
    _refreshNotes();
  }

  // メモの1行目を取得するヘルパー関数
  String _getTitle(String content) {
    if (content.isEmpty) return '（タイトルなし）';
    final lines = content.split('\n');
    return lines.first.isNotEmpty ? lines.first : '（タイトルなし）';
  }

  // メモの2行目以降を取得するヘルパー関数
  String _getSubtitle(String content) {
    if (content.isEmpty) return '';
    final lines = content.split('\n');
    if (lines.length > 1) {
      return lines.sublist(1).join('\n').trim();
    } else {
      return ''; // 2行目以降がない場合は空
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ai-MyNotes'),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('メモはありません。下の＋ボタンから作成しましょう。'));
          }

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(
                  _getTitle(note.content),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _getSubtitle(note.content),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _navigateAndRefresh(context, note: note),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
