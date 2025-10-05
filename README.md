# AllergyGuard

日本人が海外で外食する際のアレルギー対応支援Flutterアプリです。

## 主要機能

1. **レストランメニュー撮影**: カメラまたはギャラリーから画像を選択
2. **OCRでテキスト認識**: Google ML Kitを使用してメニューのテキストを自動認識
3. **自動日本語翻訳**: 認識したテキストを日本語に翻訳
4. **アレルギー情報照合**: 登録したアレルギー情報とメニューを照合
5. **危険な料理に警告表示**: アレルギー物質が含まれる料理に警告を表示

## アーキテクチャ

### ディレクトリ構造

```
lib/
├── main.dart                           # アプリケーションのエントリーポイント
├── models/                             # データモデル
│   ├── allergy.dart                    # アレルギー情報のモデル
│   └── menu_item.dart                  # メニューアイテムのモデル
├── providers/                          # 状態管理（Provider）
│   └── menu_scan_provider.dart         # メニュースキャンの状態管理
├── screens/                            # UI画面
│   ├── home_screen.dart                # ホーム画面
│   ├── allergy_settings_screen.dart    # アレルギー設定画面
│   └── scan_result_screen.dart         # スキャン結果画面
└── services/                           # ビジネスロジック
    ├── allergy_service.dart            # アレルギー情報管理サービス
    ├── camera_service.dart             # カメラ・ギャラリー操作サービス
    ├── ocr_service.dart                # OCRサービス
    └── translation_service.dart        # 翻訳サービス
```

### 使用パッケージ

- **camera**: カメラ機能
- **image_picker**: 画像選択機能
- **google_mlkit_text_recognition**: OCR（文字認識）
- **translator**: 翻訳機能
- **shared_preferences**: ローカルストレージ
- **provider**: 状態管理
- **permission_handler**: 権限管理

## セットアップ

### 前提条件

- Flutter SDK 3.7.0 以上
- Android Studio または Xcode（iOSの場合）

### インストール

1. リポジトリをクローン

```bash
git clone <repository-url>
cd allergy_guard
```

2. 依存関係をインストール

```bash
flutter pub get
```

3. アプリを実行

```bash
# Android
flutter run

# iOS (Macのみ)
flutter run -d ios
```

## 使い方

### 1. アレルギー情報の設定

初回起動時に、ホーム画面の設定ボタンまたは警告メッセージから「アレルギー設定」画面に移動し、あなたのアレルギー情報を選択します。

対応アレルギー項目:
- 小麦（wheat）
- 卵（egg）
- 乳製品（milk）
- ピーナッツ（peanut）
- ナッツ類（tree nuts）
- 甲殻類（shellfish）
- 魚（fish）
- 大豆（soy）
- ゴマ（sesame）

### 2. メニューをスキャン

1. ホーム画面で「カメラで撮影」または「ギャラリーから選択」をタップ
2. レストランのメニューを撮影または選択
3. アプリが自動的に:
   - テキストを認識（OCR）
   - 日本語に翻訳
   - アレルギー物質をチェック

### 3. 結果の確認

スキャン結果画面では:
- 撮影した画像が表示されます
- 各メニュー項目が原文と翻訳で表示されます
- アレルギー物質が検出された料理には警告マークが表示されます
- 検出されたアレルギー物質が赤いタグで表示されます

## 技術的な特徴

### 状態管理

Providerパターンを使用して、アプリ全体の状態を効率的に管理しています。`MenuScanProvider`が以下を管理:
- スキャンした画像
- OCRで認識したテキスト
- 翻訳結果
- アレルギーチェック結果
- ローディング状態
- エラーメッセージ

### サービス層

ビジネスロジックをサービス層に分離し、保守性と再利用性を向上:
- `AllergyService`: アレルギー情報の管理とチェック
- `CameraService`: カメラとギャラリーの操作
- `OcrService`: Google ML Kitを使用したOCR処理
- `TranslationService`: Google翻訳APIを使用した翻訳

### ローカルストレージ

`SharedPreferences`を使用して、ユーザーのアレルギー情報を端末に保存します。

## 権限

### Android

以下の権限が必要です（AndroidManifest.xmlに設定済み）:
- `CAMERA`: カメラ使用
- `READ_EXTERNAL_STORAGE`: ギャラリーから画像を読み込み
- `WRITE_EXTERNAL_STORAGE`: 画像を保存（Android 12以下）
- `INTERNET`: 翻訳API通信

### iOS

Info.plistに以下のキーが必要です:
- `NSCameraUsageDescription`: カメラ使用の説明
- `NSPhotoLibraryUsageDescription`: フォトライブラリアクセスの説明

## 今後の拡張予定

- [ ] オフライン翻訳機能
- [ ] より多くのアレルギー項目のサポート
- [ ] 多言語対応（英語、中国語など）
- [ ] レストラン情報の保存機能
- [ ] スキャン履歴の管理
- [ ] カスタムアレルギーキーワードの追加
- [ ] AI改善による認識精度向上

## ライセンス

このプロジェクトはプライベートプロジェクトです。

## 開発者

Created for Hackathon Project
