#!/bin/bash

# このスクリプトは、TASK.md のタスク1.2を実行した際のファイル作成処理を記録したものです。

echo "--- タスク1.2: データベース層 (レイヤー) の実装 ---"

# 1. Noteモデルクラス (note.dart) の作成
echo "[INFO] 1. lib/src/domain/note.dart を作成します..."

mkdir -p ai_my_notes/lib/src/domain

cat << 'EOF' > ai_my_notes/lib/src/domain/note.dart
class Note {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // NoteオブジェクトをMapに変換する（DB保存用）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // MapをNoteオブジェクトに変換する（DB読み込み用）
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // オブジェクトのコピーを容易にするためのcopyWithメソッド
  Note copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
EOF

# 2. データベースヘルパークラス (database_helper.dart) の作成
echo "[INFO] 2. lib/src/data/database_helper.dart を作成します..."

mkdir -p ai_my_notes/lib/src/data

cat << 'EOF' > ai_my_notes/lib/src/data/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const dateTimeType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  content $textType,
  created_at $dateTimeType,
  updated_at $dateTimeType
)
''');
  }

  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  Future<Note> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      columns: ['id', 'content', 'created_at', 'updated_at'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAll() async {
    final db = await instance.database;
    const orderBy = 'updated_at DESC';
    final result = await db.query('notes', orderBy: orderBy);

    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
EOF

echo "--- 処理コマンドの記録が完了しました ---"
