class MenuItem {
  final String originalText;
  final String translatedText;
  final List<String> detectedAllergens;
  final bool isWarning;
  final String? price; // 価格情報（オプション）
  final String? description; // 説明文（オプション）

  MenuItem({
    required this.originalText,
    required this.translatedText,
    this.detectedAllergens = const [],
    this.isWarning = false,
    this.price,
    this.description,
  });
}
