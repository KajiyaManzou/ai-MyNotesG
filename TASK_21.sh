#!/bin/bash

# Task 2.1: Implement Real-time Save Feature

echo "📝 Task 2.1: リアルタイム保存機能の実装"

# 1. NoteEditScreenを更新してリアルタイム保存を実装
echo "  - Updating NoteEditScreen to implement real-time save..."
cat << 'EOF' > ai_my_notes/lib/src/ui/note_edit_screen.dart
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
EOF

# 2. NoteEditScreenの単体テストを作成
echo "  - Creating unit tests for NoteEditScreen..."
cat << 'EOF' > ai_my_notes/test/ui/note_edit_screen_test.dart
import 'package:ai_my_notes/src/data/database_helper.dart';
import 'package:ai_my_notes/src/domain/note.dart';
import 'package:ai_my_notes/src/ui/note_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'note_edit_screen_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  group('NoteEditScreen', () {
    late MockDatabaseHelper mockDatabaseHelper;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
    });

    testWidgets('should save a new note after a delay', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.create(any)).thenAnswer((_) async => Note(id: 1, content: 'new note', createdAt: DateTime.now(), updatedAt: DateTime.now()));

      await tester.pumpWidget(
        MaterialApp(
          home: NoteEditScreen(databaseHelper: mockDatabaseHelper),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'new note');
      // Wait for the debounce timer
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      verify(mockDatabaseHelper.create(any)).called(1);
    });

    testWidgets('should update an existing note after a delay', (WidgetTester tester) async {
      // Arrange
      final existingNote = Note(id: 1, content: 'initial content', createdAt: DateTime.now(), updatedAt: DateTime.now());
      when(mockDatabaseHelper.update(any)).thenAnswer((_) async => 1);

      await tester.pumpWidget(
        MaterialApp(
          home: NoteEditScreen(note: existingNote, databaseHelper: mockDatabaseHelper),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'updated content');
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      verify(mockDatabaseHelper.update(any)).called(1);
    });

    testWidgets('should show a saving indicator', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.create(any)).thenAnswer((_) async {
        // Simulate a delay in saving
        await Future.delayed(const Duration(milliseconds: 100));
        return Note(id: 1, content: 'new note', createdAt: DateTime.now(), updatedAt: DateTime.now());
      });

      await tester.pumpWidget(
        MaterialApp(
          home: NoteEditScreen(databaseHelper: mockDatabaseHelper),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'new note');
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      // The indicator should be visible right after the debounce time
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the save operation to complete
      await tester.pumpAndSettle();

      // The indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
EOF

# 3. モックファイルを生成
echo "  - Generating mock files..."
(cd ai_my_notes && flutter pub run build_runner build)

# 4. テストを実行
echo "  - Running tests..."
(cd ai_my_notes && flutter test)

# 5. TASK.mdを更新
echo "  - Updating TASK.md..."
cat << 'EOF' > TASK.md
# ai-MyNotes 開発タスクリスト

このタスクリストは `PROPOSAL.md` の開発スケジュールに基づいています。

## フェーズ1: MVP機能の実装

### 1.1. 環境構築・プロジェクト設定
- [x] Flutter SDK のインストールとパス設定
- [x] Xcode / Android Studio のセットアップと動作確認
- [x] `flutter create ai_my_notes` でプロジェクトを作成
- [x] プロジェクトのディレクトリ構成を決定 (lib/src, lib/src/ui, lib/src/domain, lib/src/data)
- [x] `pubspec.yaml` に必要なライブラリを追加 (sqflite, path_provider など)
- [x] Linter (`analysis_options.yaml`) の設定

### 1.2. データベース層 (レイヤー) の実装
- [x] データベースヘルパークラス (`database_helper.dart`) の作成
- [x] DB接続と `notes` テーブルを作成する初期化処理の実装
- [x] Noteモデルクラス (`note.dart`) の作成 (Value Object)
- [x] メモをDBに追加するメソッドの実装 (Create)
- [x] IDでメモをDBから取得するメソッドの実装 (Read)
- [x] 全てのメモをDBから取得するメソッドの実装 (Read)
- [x] メモをDBで更新するメソッドの実装 (Update)
- [x] メモをDBから削除するメソッドの実装 (Delete)

### 1.3. UI層 (レイヤー) とドメインロジックの実装
- [x] `note_list_screen.dart` ファイルの作成
- [x] `note_edit_screen.dart` ファイルの作成
- [x] DBから全メモを取得し、リスト表示するロジックの実装
- [x] メモのタイトル・内容・更新日時を表示するリストアイテムUIの作成
- [x] メモの保存（Create/Update）ロジックの実装
- [x] 一覧と編集画面の間の画面遷移とデータ連携の実装

### 1.4. テストとリファクタリング
- [x] データベース層の単体テスト作成と実行
- [x] UI層のテスト準備（Mockitoの導入）
- [x] 依存性注入（DI）のためのリファクタリング
- [x] UI層（ウィジェットテスト）のテスト作成と実行

### 1.5. UI改善
- [x] メモ一覧をグリッド表示からカードリスト表示に変更
- [x] メモ一覧のカードに作成日時を追加

## フェーズ2: 基本機能の改善

### 2.1. リアルタイム保存
- [x] テキスト入力中にタイマーを設定し、入力が止まったら保存処理を呼び出すロジックの実装
- [x] 保存処理中にインジケーターを表示するなど、UIフィードバックの実装
- [x] リアルタイム保存ロジックの単体テスト作成

### 2.2. 全文検索
- [ ] メモ一覧画面に検索バーUIを追加
- [ ] 検索バーの入力テキストに応じて、DBに検索クエリを投げる処理の実装
- [ ] `notes` テーブルの `content` カラムに対して `LIKE` 句を使った検索メソッドをDBヘルパーに追加
- [ ] 検索結果をメモ一覧にリアルタイムで反映させるロジックの実装
- [ ] 全文検索ロジックの単体テスト作成
EOF

echo "✅ Task 2.1 has been processed."
