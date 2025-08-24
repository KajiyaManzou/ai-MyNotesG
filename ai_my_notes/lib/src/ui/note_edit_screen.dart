import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../domain/note.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  final DatabaseHelper databaseHelper;

  const NoteEditScreen({super.key, this.note, required this.databaseHelper});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _controller;
  late String _initialContent;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note?.content ?? '');
    _initialContent = widget.note?.content ?? '';
  }

  @override
  void dispose() {
    _saveNote();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final content = _controller.text;

    // 内容が空、または変更がない場合は何もしない
    if (content.isEmpty || content == _initialContent) {
      // ただし、新規作成で内容が空の場合は、DBにレコードが作られないようにする
      if (widget.note == null && content.isEmpty) {
        return;
      }
    }

    final now = DateTime.now();

    if (widget.note == null) {
      // 新規作成
      final newNote = Note(
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      await widget.databaseHelper.create(newNote);
    } else {
      // 更新
      final updatedNote = widget.note!.copyWith(
        content: content,
        updatedAt: now,
      );
      await widget.databaseHelper.update(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 戻るボタンが押されたときにも保存処理が走るようにする
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null, // 複数行の入力を許可
          expands: true, // 入力エリアを広げる
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'メモを入力',
          ),
        ),
      ),
    );
  }
}
