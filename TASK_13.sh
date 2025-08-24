#!/bin/bash

# このスクリプトは、TASK.md のタスク1.3、およびその後のテストとリファクタリング作業の実行記録です。
# 関連するファイルの最終的な内容を書き出します。

echo "--- タスク1.3: UI層の実装、テスト、リファクタリング ---"

# 1. pubspec.yaml の更新
echo "[INFO] 1. pubspec.yaml を更新します..."
cat << 'EOF' > ai_my_notes/pubspec.yaml
name: ai_my_notes
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter

  sqflite: ^2.4.2
  path_provider: ^2.1.5
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  sqflite_common_ffi: ^2.3.6
  mockito: ^5.5.0
  build_runner: ^2.7.0
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
EOF

# 2. UI関連ファイルの更新
echo "[INFO] 2. UI関連のDartファイルを更新します..."
cat << 'EOF' > ai_my_notes/lib/src/ui/note_list_screen.dart
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
EOF

cat << 'EOF' > ai_my_notes/lib/src/ui/note_edit_screen.dart
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

    if (content.isEmpty || content == _initialContent) {
      if (widget.note == null && content.isEmpty) {
        return;
      }
    }

    final now = DateTime.now();

    if (widget.note == null) {
      final newNote = Note(
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      await widget.databaseHelper.create(newNote);
    } else {
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
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'メモを入力',
          ),
        ),
      ),
    );
  }
}
EOF

# 3. main.dart の更新
echo "[INFO] 3. main.dart を更新します..."
cat << 'EOF' > ai_my_notes/lib/main.dart
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
EOF

# 4. テストファイルの作成
echo "[INFO] 4. ウィジェットテストファイルを作成します..."
mkdir -p ai_my_notes/test/ui
cat << 'EOF' > ai_my_notes/test/ui/note_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ai_my_notes/src/data/database_helper.dart';
import 'package:ai_my_notes/src/domain/note.dart';
import 'package:ai_my_notes/src/ui/note_list_screen.dart';
import 'package:ai_my_notes/src/ui/note_edit_screen.dart';

@GenerateMocks([DatabaseHelper])
import 'note_list_screen_test.mocks.dart';

void main() {
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: NoteListScreen(databaseHelper: mockDatabaseHelper),
    );
  }

  testWidgets('メモがない場合、「メモはありません」と表示されること', (WidgetTester tester) async {
    when(mockDatabaseHelper.readAll()).thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('メモはありません。下の＋ボタンから作成しましょう。'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('メモがある場合、リストが表示されること', (WidgetTester tester) async {
    final mockNotes = [
      Note(id: 1, content: 'テスト1\n内容1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      Note(id: 2, content: 'テスト2\n内容2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ];
    when(mockDatabaseHelper.readAll()).thenAnswer((_) async => mockNotes);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('テスト1'), findsOneWidget);
    expect(find.text('内容1'), findsOneWidget);
    expect(find.text('テスト2'), findsOneWidget);
  });

  testWidgets('FABをタップすると編集画面に遷移すること', (WidgetTester tester) async {
    when(mockDatabaseHelper.readAll()).thenAnswer((_) async => []);
    when(mockDatabaseHelper.create(any)).thenAnswer((_) async => 
        Note(id: 1, content: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditScreen), findsOneWidget);
  });
}
EOF

# 5. ユーザーが実行したコマンドの記録
echo "[INFO] 5. ユーザーに以下のコマンドの実行を依頼しました:"
echo "   flutter pub get"

echo "   flutter pub run build_runner build --delete-conflicting-outputs"

echo "   flutter test (結果: 全てパス)"

echo "--- 処理コマンドの記録が完了しました ---"
