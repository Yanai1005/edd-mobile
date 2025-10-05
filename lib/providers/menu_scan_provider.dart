import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/text_block.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/translation_service.dart';
import '../services/allergy_service.dart';
import '../services/layout_analysis_service.dart';

class MenuScanProvider with ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final OcrService _ocrService = OcrService();
  final TranslationService _translationService = TranslationService();
  final AllergyService _allergyService = AllergyService();
  final LayoutAnalysisService _layoutService = LayoutAnalysisService();

  File? _scannedImage;
  String _recognizedText = '';
  List<MenuItem> _menuItems = [];
  List<TextBlock> _textBlocks = [];
  List<String> _userAllergies = [];
  bool _isLoading = false;
  String? _errorMessage;

  File? get scannedImage => _scannedImage;
  String get recognizedText => _recognizedText;
  List<MenuItem> get menuItems => _menuItems;
  List<TextBlock> get textBlocks => _textBlocks;
  List<String> get userAllergies => _userAllergies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MenuScanProvider() {
    _loadUserAllergies();
  }

  // ユーザーのアレルギー情報を読み込み
  Future<void> _loadUserAllergies() async {
    _userAllergies = await _allergyService.loadUserAllergies();
    notifyListeners();
  }

  // ユーザーのアレルギー情報を更新
  Future<void> updateUserAllergies(List<String> allergies) async {
    _userAllergies = allergies;
    await _allergyService.saveUserAllergies(allergies);

    // 既存のメニューアイテムを再チェック
    if (_menuItems.isNotEmpty) {
      _recheckMenuItems();
    }

    notifyListeners();
  }

  // カメラで撮影
  Future<void> takePicture() async {
    try {
      _setLoading(true);
      _clearError();

      final image = await _cameraService.takePicture();
      if (image != null) {
        _scannedImage = image;
        await _processImage();
      }
    } catch (e) {
      _setError('撮影に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ギャラリーから選択
  Future<void> pickFromGallery() async {
    try {
      _setLoading(true);
      _clearError();

      final image = await _cameraService.pickFromGallery();
      if (image != null) {
        _scannedImage = image;
        await _processImage();
      }
    } catch (e) {
      _setError('画像の選択に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 画像を処理（OCR → 翻訳 → アレルギーチェック）
  Future<void> _processImage() async {
    if (_scannedImage == null) return;

    try {
      _setLoading(true);
      _clearError();

      // 1. OCRでテキストと位置情報を認識
      _textBlocks = await _ocrService.recognizeTextWithPosition(_scannedImage!);

      if (_textBlocks.isEmpty) {
        _setError('テキストを認識できませんでした');
        return;
      }

      // 認識されたテキストを結合
      _recognizedText = _textBlocks.map((block) => block.text).join('\n');

      // 2. 各テキストブロックを翻訳してアレルギーチェック
      final updatedBlocks = <TextBlock>[];
      _menuItems = [];

      for (final block in _textBlocks) {
        // 翻訳（失敗時は元のテキストを使用）
        String translated;
        try {
          translated = await _translationService.translate(block.text);
          // 翻訳結果が空の場合は元のテキストを使用
          if (translated.trim().isEmpty) {
            translated = block.text;
          }
        } catch (e) {
          // 翻訳失敗時は元のテキストを使用
          translated = block.text;
          print('翻訳エラー: $e');
        }

        // アレルギーチェック（総合的な検出）
        final detectedAllergens = _allergyService.detectAllergensComprehensive(
          block.text,
          translated,
          _userAllergies,
        );

        // TextBlockを更新
        final updatedBlock = block.copyWith(
          translatedText: translated,
          detectedAllergens: detectedAllergens,
          isWarning: detectedAllergens.isNotEmpty,
        );
        updatedBlocks.add(updatedBlock);

        // MenuItemも作成（料理名と思われるもののみ）
        if (_isLikelyMenuItem(block.text, translated)) {
          _menuItems.add(
            MenuItem(
              originalText: block.text,
              translatedText: translated,
              detectedAllergens: detectedAllergens,
              isWarning: detectedAllergens.isNotEmpty,
            ),
          );
        }
      }

      _textBlocks = updatedBlocks;
      notifyListeners();
    } catch (e) {
      _setError('画像の処理に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // メニューアイテムを再チェック
  void _recheckMenuItems() {
    final updatedItems = <MenuItem>[];
    final updatedBlocks = <TextBlock>[];

    for (final item in _menuItems) {
      final detectedAllergens = _allergyService.detectAllergens(
        item.originalText,
        _userAllergies,
      );

      updatedItems.add(
        MenuItem(
          originalText: item.originalText,
          translatedText: item.translatedText,
          detectedAllergens: detectedAllergens,
          isWarning: detectedAllergens.isNotEmpty,
        ),
      );
    }

    // TextBlocksも更新
    for (final block in _textBlocks) {
      final detectedAllergens = _allergyService.detectAllergens(
        block.text,
        _userAllergies,
      );

      updatedBlocks.add(
        block.copyWith(
          detectedAllergens: detectedAllergens,
          isWarning: detectedAllergens.isNotEmpty,
        ),
      );
    }

    _menuItems = updatedItems;
    _textBlocks = updatedBlocks;
  }

  // テキストが料理名らしいかどうかを判定
  bool _isLikelyMenuItem(String original, String translated) {
    final text = original.toLowerCase();
    final translatedLower = translated.toLowerCase();

    // 除外パターン1: 価格を示すもの
    final pricePatterns = [
      r'\$', // ドル記号
      r'¥', // 円記号
      r'円',
      r'￥',
      r'\d+\s*yen',
      r'\d+\s*dollar',
      r'\d+\s*usd',
      r'^\d+$', // 数字のみ
      r'^\d+\.\d+$', // 小数点付き数字のみ
      r'%', // パーセント記号
      r'％', // 全角パーセント
    ];

    for (final pattern in pricePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return false;
      }
    }

    // 除外パターン2: サイズや単位を示すもの
    final sizePatterns = [
      r'\d+\s*g\b', // グラム
      r'\d+\s*ml\b', // ミリリットル
      r'\d+\s*l\b', // リットル
      r'\d+\s*kg\b', // キログラム
      r'\d+\s*oz\b', // オンス
      r'\d+\s*lb\b', // ポンド
      r'\d+\s*cm\b', // センチメートル
      r'\d+\s*個\b', // 個数
      r'\d+\s*人前\b', // 人前
      // サイズ表記は除外しない（料理名に含まれる可能性があるため）
    ];

    for (final pattern in sizePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return false;
      }
    }

    // 除外パターン3: 1文字のみのテキストは除外（2文字以上はOK）
    if (original.trim().length <= 1) {
      return false;
    }

    // 除外パターン3.5: 装飾的な記号のみ（ドット、ダッシュ、アスタリスクなど）
    if (RegExp(r'^[\.\-_=\*~]+$').hasMatch(original.trim())) {
      return false;
    }

    // 除外パターン4: 数字のみで構成されているもの
    if (RegExp(r'^[\d\s\.\,\-\/]+$').hasMatch(text)) {
      return false;
    }

    // 除外パターン5: 特殊文字のみ
    if (RegExp(r'^[\W_]+$').hasMatch(text)) {
      return false;
    }

    // 除外パターン6: 一般的なメニュー用語（ヘッダーなど）- より限定的に
    final headerPatterns = [
      r'^menu$',
      r'^メニュー$',
      r'^category$',
      r'^カテゴリー?$',
    ];

    for (final pattern in headerPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(translatedLower)) {
        return false;
      }
    }

    // 通過したものは料理名として扱う
    return true;
  }

  // スキャン結果をクリア
  void clearScan() {
    _scannedImage = null;
    _recognizedText = '';
    _menuItems = [];
    _textBlocks = [];
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
