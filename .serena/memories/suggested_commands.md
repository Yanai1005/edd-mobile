# 推奨開発コマンド

## Flutter 開発

# 開発サーバー起動
flutter run

# ホットリロード（開発中）
# r キーを押す

# デバッグモード
flutter run --debug

# リリースビルド
flutter build apk          # Android
flutter build ios          # iOS

# 依存関係インストール
flutter pub get

# 依存関係更新
flutter pub upgrade

# コード解析
flutter analyze

# テスト実行
flutter test

# コードフォーマット
dart format .

## パッケージ追加

# 画像・カメラ関連
flutter pub add camera
flutter pub add image_picker
flutter pub add google_mlkit_text_recognition

# 翻訳・API通信
flutter pub add http
flutter pub add translator

# データ管理
flutter pub add sqflite
flutter pub add shared_preferences
flutter pub add path_provider

# 状態管理
flutter pub add provider

## デバイス管理

# 接続デバイス確認
flutter devices

# エミュレータ起動
flutter emulators --launch <emulator_id>

## クリーンビルド

flutter clean
flutter pub get
flutter run
