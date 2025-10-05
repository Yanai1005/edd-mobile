import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/translation_service.dart';
import '../services/allergy_service.dart';

class MenuScanProvider with ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final OcrService _ocrService = OcrService();
  final TranslationService _translationService = TranslationService();
  final AllergyService _allergyService = AllergyService();

  File? _scannedImage;
  String _recognizedText = '';
  List<MenuItem> _menuItems = [];
  List<String> _userAllergies = [];
  bool _isLoading = false;
  String? _errorMessage;

  File? get scannedImage => _scannedImage;
  String get recognizedText => _recognizedText;
  List<MenuItem> get menuItems => _menuItems;
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

      // 1. OCRでテキストを認識
      _recognizedText = await _ocrService.recognizeText(_scannedImage!);
      
      if (_recognizedText.isEmpty) {
        _setError('テキストを認識できませんでした');
        return;
      }

      // 2. テキストを日本語に翻訳
      final translations = await _translationService.translateLines(_recognizedText);

      // 3. アレルギー物質をチェック
      _menuItems = [];
      for (final entry in translations.entries) {
        final detectedAllergens = _allergyService.detectAllergens(
          entry.key,
          _userAllergies,
        );

        _menuItems.add(MenuItem(
          originalText: entry.key,
          translatedText: entry.value,
          detectedAllergens: detectedAllergens,
          isWarning: detectedAllergens.isNotEmpty,
        ));
      }

      notifyListeners();
    } catch (e) {
      _setError('画像の処理に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // メニューアイテムを再チェック
  void _recheckMenuItems() {
    _menuItems = _menuItems.map((item) {
      final detectedAllergens = _allergyService.detectAllergens(
        item.originalText,
        _userAllergies,
      );

      return MenuItem(
        originalText: item.originalText,
        translatedText: item.translatedText,
        detectedAllergens: detectedAllergens,
        isWarning: detectedAllergens.isNotEmpty,
      );
    }).toList();
  }

  // スキャン結果をクリア
  void clearScan() {
    _scannedImage = null;
    _recognizedText = '';
    _menuItems = [];
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
