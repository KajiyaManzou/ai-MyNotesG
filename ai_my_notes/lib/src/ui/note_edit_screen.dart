import 'dart:async';

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
  Timer? _debounce;
  bool _isSaving = false;
  
  // widget.note をステートとして持つ
  Note? _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _controller = TextEditingController(text: _note?.content ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // 画面が破棄される直前に、最後の変更を確実に保存する
    _saveNote(force: true);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _saveNote();
    });
  }

  Future<void> _saveNote({bool force = false}) async {
    final content = _controller.text;

    // 強制保存でない場合、内容が空なら何もしない
    if (!force && content.isEmpty) {
      return;
    }
    
    // 変更がない場合は何もしない
    if (_note != null && content == _note!.content) {
      return;
    }

    if (mounted && !force) {
      setState(() {
        _isSaving = true;
      });
    }

    final now = DateTime.now();

    if (_note == null) {
      // 新規作成
      final newNote = Note(
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      // insert した note には id がセットされる
      final savedNote = await widget.databaseHelper.create(newNote);
      // state を更新して、次回以降が更新になるようにする
      _note = savedNote;

    } else {
      // 更新
      final updatedNote = _note!.copyWith(
        content: content,
        updatedAt: now,
      );
      await widget.databaseHelper.update(updatedNote);
      _note = updatedNote;
    }

    if (mounted && !force) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
            ),
        ],
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
