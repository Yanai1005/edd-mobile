class MenuItem {
  final String originalText;
  final String translatedText;
  final List<String> detectedAllergens;
  final bool isWarning;

  MenuItem({
    required this.originalText,
    required this.translatedText,
    this.detectedAllergens = const [],
    this.isWarning = false,
  });
}
