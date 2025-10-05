import 'package:shared_preferences/shared_preferences.dart';
import '../models/allergy.dart';

class AllergyService {
  static const String _storageKey = 'user_allergies';

  // 主要なアレルギー項目のリスト
  static List<Allergy> getAllergies() {
    return [
      Allergy(
        name: '小麦',
        nameEn: 'wheat',
        keywords: ['wheat', 'flour', 'bread', 'pasta', 'noodle', 'gluten'],
      ),
      Allergy(
        name: '卵',
        nameEn: 'egg',
        keywords: ['egg', 'eggs', 'mayonnaise', 'mayo'],
      ),
      Allergy(
        name: '乳製品',
        nameEn: 'milk',
        keywords: ['milk', 'dairy', 'cheese', 'butter', 'cream', 'yogurt'],
      ),
      Allergy(
        name: 'ピーナッツ',
        nameEn: 'peanut',
        keywords: ['peanut', 'peanuts', 'groundnut'],
      ),
      Allergy(
        name: 'ナッツ類',
        nameEn: 'tree nuts',
        keywords: ['nuts', 'almond', 'cashew', 'walnut', 'pecan', 'pistachio'],
      ),
      Allergy(
        name: '甲殻類',
        nameEn: 'shellfish',
        keywords: ['shrimp', 'crab', 'lobster', 'prawn', 'shellfish', 'crayfish'],
      ),
      Allergy(
        name: '魚',
        nameEn: 'fish',
        keywords: ['fish', 'salmon', 'tuna', 'cod', 'anchovy'],
      ),
      Allergy(
        name: '大豆',
        nameEn: 'soy',
        keywords: ['soy', 'soya', 'tofu', 'edamame', 'soybean'],
      ),
      Allergy(
        name: 'ゴマ',
        nameEn: 'sesame',
        keywords: ['sesame', 'tahini'],
      ),
    ];
  }

  // ユーザーのアレルギー情報を保存
  Future<void> saveUserAllergies(List<String> allergyNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, allergyNames);
  }

  // ユーザーのアレルギー情報を読み込み
  Future<List<String>> loadUserAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_storageKey) ?? [];
  }

  // テキストからアレルギー物質を検出
  List<String> detectAllergens(String text, List<String> userAllergies) {
    final detectedAllergens = <String>[];
    final lowerText = text.toLowerCase();
    final allergies = getAllergies();

    for (final allergyName in userAllergies) {
      final allergy = allergies.firstWhere(
        (a) => a.name == allergyName,
        orElse: () => Allergy(name: '', nameEn: '', keywords: []),
      );

      if (allergy.name.isEmpty) continue;

      for (final keyword in allergy.keywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          detectedAllergens.add(allergy.name);
          break;
        }
      }
    }

    return detectedAllergens;
  }
}
