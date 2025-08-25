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