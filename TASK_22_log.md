Command: cd ai_my_notes && flutter test test/ui/note_list_screen_test.dart
Directory: (root)
Output: 00:00 +0: loading /Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart                                                                                                      00:01 +0: loading /Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart                                                                                                      00:01 +0: メモがない場合、「メモはありません」と表示されること                                                                                                                                                                   00:01 +1: メモがない場合、「メモはありません」と表示されること                                                                                                                                                                   00:01 +1: メモがある場合、カードのリストが表示されること                                                                                                                                                                      00:01 +1: メモがある場合、カードのリストが表示されること                                                                                                                                                                      
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "テスト1": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart:55:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:193:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1064:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart line 55
The test description was:
  メモがある場合、カードのリストが表示されること
════════════════════════════════════════════════════════════════════════════════════════════════════
00:01 +1 -1: メモがある場合、カードのリストが表示されること [E]                                                                                                                                                               
  Test failed. See exception logs above.
  The test description was: メモがある場合、カードのリストが表示されること
  

To run this test again: /Users/hobara/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart -p vm --plain-name 'メモがある場合、カードのリストが表示されること'
00:01 +1 -1: FABをタップすると編集画面に遷移すること                                                                                                                                                                     00:01 +2 -1: FABをタップすると編集画面に遷移すること                                                                                                                                                                     00:01 +2 -1: 検索バーに入力すると、メモがフィルタリングされること                                                                                                                                                                00:01 +2 -1: 検索バーに入力すると、メモがフィルタリングされること                                                                                                                                                                
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _AncestorWidgetFinder:<Found 0 widgets with type "Card" that are ancestors of widgets with
text "Apple": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart:97:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:193:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1064:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart line 97
The test description was:
  検索バーに入力すると、メモがフィルタリングされること
════════════════════════════════════════════════════════════════════════════════════════════════════
00:01 +2 -2: 検索バーに入力すると、メモがフィルタリングされること [E]                                                                                                                                                            
  Test failed. See exception logs above.
  The test description was: 検索バーに入力すると、メモがフィルタリングされること
  

To run this test again: /Users/hobara/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart -p vm --plain-name '検索バーに入力すると、メモがフィルタリングされること'
00:01 +2 -2: 検索バーをクリアすると、すべてのメモが表示されること                                                                                                                                                                00:02 +3 -2: 検索バーをクリアすると、すべてのメモが表示されること                                                                                                                                                                00:02 +3 -2: 検索キーワードがハイライト表示されること                                                                                                                                                                      00:02 +3 -2: 検索キーワードがハイライト表示されること                                                                                                                                                                      00:02 +3 -3: 検索キーワードがハイライト表示されること [E]                                                                                                                                                                  
  Test failed. See exception logs above.
  The test description was: 検索キーワードがハイライト表示されること
  

To run this test again: /Users/hobara/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/hobara/dev/AI/ai-MyNotesG/ai_my_notes/test/ui/note_list_screen_test.dart -p vm --plain-name '検索キーワードがハイライト表示されること'
00:02 +3 -3: Some tests failed.
Error: (none)
Exit Code: 1
Signal: (none)
Background PIDs: (none)
Process Group PGID: 68063