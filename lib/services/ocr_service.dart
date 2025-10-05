import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/text_block.dart' as models;
import 'dart:ui';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // 画像からテキストを認識（単純版 - 後方互換性のため）
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      throw Exception('OCR処理に失敗しました: $e');
    }
  }

  // 画像からテキストと位置情報を認識
  Future<List<models.TextBlock>> recognizeTextWithPosition(
    File imageFile,
  ) async {
    // 画像からテキストと位置情報を認識
    Future<List<models.TextBlock>> recognizeTextWithPosition(
      File imageFile,
    ) async {
      try {
        final inputImage = InputImage.fromFile(imageFile);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        final textBlocks = <models.TextBlock>[];

        // ブロック単位で処理（料理名など意味のある単位でまとまる）
        for (final block in recognizedText.blocks) {
          final boundingBox = block.boundingBox;

          // RectをdartのRectに変換
          final rect = Rect.fromLTRB(
            boundingBox.left.toDouble(),
            boundingBox.top.toDouble(),
            boundingBox.right.toDouble(),
            boundingBox.bottom.toDouble(),
          );

          textBlocks.add(
            models.TextBlock(
              text: block.text,
              boundingBox: rect,
              translatedText: '', // 後で翻訳を設定
            ),
          );
        }

        return textBlocks;
      } catch (e) {
        throw Exception('OCR処理に失敗しました: $e');
      }
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final textBlocks = <models.TextBlock>[];

      // 各テキストブロックの情報を取得
      for (final block in recognizedText.blocks) {
        // ブロック全体ではなく、行ごとに処理
        for (final line in block.lines) {
          final boundingBox = line.boundingBox;

          // RectをdartのRectに変換
          final rect = Rect.fromLTRB(
            boundingBox.left.toDouble(),
            boundingBox.top.toDouble(),
            boundingBox.right.toDouble(),
            boundingBox.bottom.toDouble(),
          );

          textBlocks.add(
            models.TextBlock(
              text: line.text,
              boundingBox: rect,
              translatedText: '', // 後で翻訳を設定
            ),
          );
        }
      }

      return textBlocks;
    } catch (e) {
      throw Exception('OCR処理に失敗しました: $e');
    }
  }

  // リソースの解放
  void dispose() {
    _textRecognizer.close();
  }
}
