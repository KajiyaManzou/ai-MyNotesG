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
