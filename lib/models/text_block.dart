import 'dart:ui';

/// OCRで認識されたテキストブロックの情報
class TextBlock {
  final String text;
  final Rect boundingBox;
  final String translatedText;
  final List<String> detectedAllergens;
  final bool isWarning;

  TextBlock({
    required this.text,
    required this.boundingBox,
    required this.translatedText,
    this.detectedAllergens = const [],
    this.isWarning = false,
  });

  TextBlock copyWith({
    String? text,
    Rect? boundingBox,
    String? translatedText,
    List<String>? detectedAllergens,
    bool? isWarning,
  }) {
    return TextBlock(
      text: text ?? this.text,
      boundingBox: boundingBox ?? this.boundingBox,
      translatedText: translatedText ?? this.translatedText,
      detectedAllergens: detectedAllergens ?? this.detectedAllergens,
      isWarning: isWarning ?? this.isWarning,
    );
  }
}
