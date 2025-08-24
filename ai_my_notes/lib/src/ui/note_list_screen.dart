import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日付フォーマットのために追加
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

  String _getTitle(String content) {
    if (content.isEmpty) return '（タイトルなし）';
    final lines = content.split('\n');
    return lines.first.isNotEmpty ? lines.first : '（タイトルなし）';
  }

  String _getSubtitle(String content) {
    if (content.isEmpty) return '';
    final lines = content.split('\n');
    if (lines.length > 1) {
      return lines.sublist(1).join('\n').trim();
    } else {
      return '';
    }
  }

  String _formatDateTime(DateTime dt) {
    // YYYY/MM/dd HH:mm 形式でフォーマット
    return DateFormat('yyyy/MM/dd HH:mm').format(dt);
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: InkWell(
                  onTap: () => _navigateAndRefresh(context, note: note),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitle(note.content),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSubtitle(note.content),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatDateTime(note.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
