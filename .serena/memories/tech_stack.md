# 技術スタック

## フレームワーク
- **Flutter**: 3.29.0
- **Dart SDK**: ^3.7.0

## 主要パッケージ（予定）

### OCR・画像認識
- **google_mlkit_text_recognition**: テキスト認識（オンデバイス）
- **camera**: カメラアクセス
- **image_picker**: 画像選択

### 翻訳API
- **google_translate**: Google翻訳API
- **http**: API通信

### データ管理
- **sqflite**: ローカルデータベース
- **shared_preferences**: アレルギー情報保存

### 状態管理
- **provider** または **riverpod**: 状態管理

### UI/UX
- **flutter_svg**: アイコン表示
- **flutter_markdown**: 翻訳結果表示

## 開発環境
- **IDE**: VS Code / Android Studio
- **ビルドツール**: Gradle (Android), Xcode (iOS)
- **コード品質**: flutter_lints 5.0.0

## 外部API
- **Google Cloud Vision API**: OCR（オプション・高精度が必要な場合）
- **Google Cloud Translation API**: 翻訳
- **ChatGPT API**: アレルギー成分判定補助（オプション）
