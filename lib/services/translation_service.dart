import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  // テキストを日本語に翻訳
  Future<String> translateToJapanese(String text) async {
    if (text.isEmpty) return '';
    
    try {
      final translation = await _translator.translate(
        text,
        to: 'ja',
      );
      return translation.text;
    } catch (e) {
      throw Exception('翻訳に失敗しました: $e');
    }
  }

  // 複数行のテキストを翻訳
  Future<Map<String, String>> translateLines(String text) async {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);
    final translations = <String, String>{};

    for (final line in lines) {
      try {
        final translated = await translateToJapanese(line);
        translations[line] = translated;
      } catch (e) {
        translations[line] = line; // 翻訳失敗時は元のテキストを使用
      }
    }

    return translations;
  }

  // 単一のテキストを翻訳（エイリアス）
  Future<String> translate(String text) => translateToJapanese(text);
}
