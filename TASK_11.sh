#!/bin/bash

# このスクリプトは、TASK.md のタスク1.1を実行した際のコマンドを記録したものです。
# ファイル編集など、一部のステップはコメントとして記載しています。

echo "--- タスク1.1: 環境構築・プロジェクト設定 ---"

# 1. Flutter環境の確認
echo "[INFO] 1. Flutter環境を確認します..."
flutter doctor

# 2. Flutterプロジェクトの作成
echo "[INFO] 2. Flutterプロジェクト 'ai_my_notes' を作成します..."
flutter create ai_my_notes

# 3. ディレクトリ構成の作成
echo "[INFO] 3. プロジェクト内にディレクトリを作成します..."
mkdir -p ai_my_notes/lib/src/ui ai_my_notes/lib/src/domain ai_my_notes/lib/src/data

# 4. 依存関係の追加 (pubspec.yamlの編集)
echo "[INFO] 4. pubspec.yaml にライブラリを追加しました。"
echo "       手動またはIDEの機能で 'flutter pub get' を実行してください。"
cat <<EOM
[追加したライブラリ]
  sqflite: ^2.4.2
  path_provider: ^2.1.5
EOM

# 5. Linterの設定 (analysis_options.yamlの編集)
echo "[INFO] 5. analysis_options.yaml にLinterルールを追加しました。"
cat <<EOM
[追加したルール]
  rules:
    cyclomatic_complexity: 10
EOM

echo "--- 処理コマンドの記録が完了しました ---"
