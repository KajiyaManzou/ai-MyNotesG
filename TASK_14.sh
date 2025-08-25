#!/bin/bash

# このスクリプトは、TASK.md のタスク1.4および1.5の実行記録です。
# UI改善と、それに伴うテストの修正・削除を反映します。

echo "--- タスク1.4 & 1.5: UI改善とテスト修正 ---"

# 1. intl パッケージの追加
echo "[INFO] 1. pubspec.yaml に intl パッケージを追加します..."
# pubspec.yaml の dependencies に intl を追加するコマンド (手動で実施済みと想定)
# flutter pub add intl

# 2. note_list_screen.dart の更新 (UI改善)
echo "[INFO] 2. note_list_screen.dart を更新してUIを改善します..."
cat << 'EOF' > ai_my_notes/lib/src/ui/note_list_screen.dart
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
EOF

# 3. note_list_screen_test.dart の更新
echo "[INFO] 3. note_list_screen_test.dart をUI改善に合わせて更新します..."
cat << 'EOF' > ai_my_notes/test/ui/note_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:intl/intl.dart';

import 'package:ai_my_notes/src/data/database_helper.dart';
import 'package:ai_my_notes/src/domain/note.dart';
import 'package:ai_my_notes/src/ui/note_list_screen.dart';
import 'package:ai_my_notes/src/ui/note_edit_screen.dart';

// Generate a MockDatabaseHelper class.
@GenerateMocks([DatabaseHelper])
import 'note_list_screen_test.mocks.dart';

void main() {
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
  });

  // Helper function to pump the widget with necessary ancestors
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: NoteListScreen(databaseHelper: mockDatabaseHelper),
    );
  }

  String formatDateTime(DateTime dt) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dt);
  }

  testWidgets('メモがない場合、「メモはありません」と表示されること', (WidgetTester tester) async {
    // Arrange
    when(mockDatabaseHelper.readAll()).thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for the FutureBuilder to resolve

    // Assert
    expect(find.text('メモはありません。下の＋ボタンから作成しましょう。'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('メモがある場合、カードのリストが表示されること', (WidgetTester tester) async {
    // Arrange
    final now = DateTime.now();
    final mockNotes = [
      Note(id: 1, content: 'テスト1\n内容1', createdAt: now, updatedAt: now),
      Note(id: 2, content: 'テスト2\n内容2', createdAt: now, updatedAt: now),
    ];
    when(mockDatabaseHelper.readAll()).thenAnswer((_) async => mockNotes);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2)); // カードが2つ表示されることを確認
    expect(find.text('テスト1'), findsOneWidget);
    expect(find.text('内容1'), findsOneWidget);
    expect(find.text(formatDateTime(now)), findsNWidgets(2)); // 日付がフォーマットされて表示されることを確認
  });

  testWidgets('FABをタップすると編集画面に遷移すること', (WidgetTester tester) async {
    // Arrange
    when(mockDatabaseHelper.readAll()).thenAnswer((_) async => []);
    // Mock the create call that happens in NoteEditScreen
    when(mockDatabaseHelper.create(any)).thenAnswer((_) async => 
        Note(id: 1, content: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(NoteEditScreen), findsOneWidget);
  });
}
EOF

# 4. 不要なテストファイルの削除
echo "[INFO] 4. 不要になった widget_test.dart を削除します..."
rm ai_my_notes/test/widget_test.dart

# 5. ユーザーが実行したコマンドの記録
echo "[INFO] 5. ユーザーに以下のコマンドの実行を依頼しました:"
echo "   flutter test (結果: 全てパス)"

echo "--- 処理コマンドの記録が完了しました ---"
