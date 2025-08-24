import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ai_my_notes/src/data/database_helper.dart';
import 'package:ai_my_notes/src/domain/note.dart';

// main関数でテストを実行するために必要
void main() {
  // FFIを初期化して、テスト中にsqfliteが動作するようにする
  setUpAll(() {
    sqfliteFfiInit();
    // テスト用のデータベースファクトリを設定
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // 各テストの前に、インメモリデータベースでDatabaseHelperを初期化
      dbHelper = DatabaseHelper.instance;
      // テストごとにDBをクリーンにする
      final db = await dbHelper.database;
      await db.delete('notes'); 
    });

    test('メモを作成し、IDで読み取れること', () async {
      // Arrange
      final now = DateTime.now();
      final noteToCreate = Note(
        content: 'テストメモ\nこれはテストです。',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final createdNote = await dbHelper.create(noteToCreate);
      final readNote = await dbHelper.read(createdNote.id!);

      // Assert
      expect(readNote.id, createdNote.id);
      expect(readNote.content, noteToCreate.content);
      // DBの精度によりミリ秒以下が丸められることがあるため、大まかな比較
      expect(readNote.createdAt.toIso8601String().substring(0, 19), 
             noteToCreate.createdAt.toIso8601String().substring(0, 19));
    });

    test('すべてのメモを更新日時順（降順）で読み取れること', () async {
      // Arrange
      final note1 = Note(content: 'メモ1', createdAt: DateTime.now(), updatedAt: DateTime.now().add(const Duration(minutes: 1)));
      final note2 = Note(content: 'メモ2', createdAt: DateTime.now(), updatedAt: DateTime.now());
      await dbHelper.create(note2);
      await dbHelper.create(note1);

      // Act
      final allNotes = await dbHelper.readAll();

      // Assert
      expect(allNotes.length, 2);
      expect(allNotes[0].content, 'メモ1'); // note1が更新日時が新しいので先頭
      expect(allNotes[1].content, 'メモ2');
    });

    test('メモを更新できること', () async {
      // Arrange
      final note = await dbHelper.create(Note(content: '初期コンテンツ', createdAt: DateTime.now(), updatedAt: DateTime.now()));
      final updatedContent = '更新されたコンテンツ';
      final updatedNote = note.copyWith(content: updatedContent, updatedAt: DateTime.now().add(const Duration(seconds: 1)));

      // Act
      await dbHelper.update(updatedNote);
      final readNote = await dbHelper.read(note.id!);

      // Assert
      expect(readNote.content, updatedContent);
    });

    test('メモを削除できること', () async {
      // Arrange
      final note = await dbHelper.create(Note(content: '削除するメモ', createdAt: DateTime.now(), updatedAt: DateTime.now()));
      expect((await dbHelper.readAll()).length, 1);

      // Act
      await dbHelper.delete(note.id!);

      // Assert
      expect((await dbHelper.readAll()).isEmpty, true);
    });
  });
}
