import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer? _textRecognizer = kIsWeb ? null : TextRecognizer();

  // 画像からテキストを認識
  Future<String> recognizeText(dynamic imageFile) async {
    try {
      // Web版ではデモテキストを返す
      if (kIsWeb) {
        return _getDemoText();
      }
      
      // モバイル版ではML KitでOCR処理
      if (_textRecognizer == null) {
        throw Exception('OCRサービスが初期化されていません');
      }
      
      final inputImage = InputImage.fromFile(imageFile as File);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      throw Exception('OCR処理に失敗しました: $e');
    }
  }

  // Web版用のデモテキスト
  String _getDemoText() {
    return '''Grilled Salmon with butter sauce
Caesar Salad with cheese
Spaghetti Carbonara with eggs
Chicken Teriyaki
Shrimp Tempura
Beef Steak with peanut sauce
Vegetable Soup
Tuna Sandwich''';
  }

  // リソースの解放
  void dispose() {
    _textRecognizer?.close();
  }
}
