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
        keywords: [
          'wheat', 'flour', 'bread', 'pasta', 'noodle', 'noodles', 'gluten',
          'spaghetti', 'udon', 'ramen', 'soba', 'pizza', 'dough',
          'tempura', 'breaded', 'battered', 'crouton', 'couscous',
          'semolina', 'durum', 'farro', 'spelt', 'cake', 'cookie',
          'biscuit', 'pancake', 'waffle', 'tortilla', 'burrito', 'wrap',
        ],
      ),
      Allergy(
        name: '卵',
        nameEn: 'egg',
        keywords: [
          'egg', 'eggs', 'mayonnaise', 'mayo', 'omelette', 'omelet',
          'scrambled', 'fried egg', 'boiled egg', 'poached egg',
          'meringue', 'custard', 'quiche', 'frittata', 'deviled',
          'aioli', 'hollandaise', 'carbonara', 'tamago', 'tamagoyaki',
        ],
      ),
      Allergy(
        name: '乳製品',
        nameEn: 'milk',
        keywords: [
          'milk', 'dairy', 'cheese', 'butter', 'cream', 'yogurt', 'yoghurt',
          'mozzarella', 'parmesan', 'cheddar', 'brie', 'feta', 'goat cheese',
          'ice cream', 'gelato', 'whipped cream', 'sour cream', 'creamy',
          'bechamel', 'alfredo', 'ricotta', 'mascarpone', 'condensed milk',
          'evaporated milk', 'milk chocolate', 'lactose', 'casein', 'whey',
        ],
      ),
      Allergy(
        name: 'ピーナッツ',
        nameEn: 'peanut',
        keywords: [
          'peanut', 'peanuts', 'groundnut', 'groundnuts', 'peanut butter',
          'peanut oil', 'peanut sauce', 'satay', 'goobers', 'monkey nuts',
        ],
      ),
      Allergy(
        name: 'ナッツ類',
        nameEn: 'tree nuts',
        keywords: [
          'nuts', 'almond', 'almonds', 'cashew', 'cashews', 'walnut', 'walnuts',
          'pecan', 'pecans', 'pistachio', 'pistachios', 'hazelnut', 'hazelnuts',
          'macadamia', 'brazil nut', 'pine nut', 'pine nuts', 'chestnut',
          'chestnuts', 'praline', 'marzipan', 'nougat', 'gianduja',
        ],
      ),
      Allergy(
        name: '甲殻類',
        nameEn: 'shellfish',
        keywords: [
          'shrimp', 'shrimps', 'prawn', 'prawns', 'crab', 'crabs', 'lobster',
          'crayfish', 'crawfish', 'shellfish', 'langoustine', 'scampi',
          'clam', 'clams', 'mussel', 'mussels', 'oyster', 'oysters',
          'scallop', 'scallops', 'seafood', 'ebi', 'kani',
        ],
      ),
      Allergy(
        name: '魚',
        nameEn: 'fish',
        keywords: [
          'fish', 'salmon', 'tuna', 'cod', 'haddock', 'halibut', 'trout',
          'sea bass', 'seabass', 'anchovy', 'anchovies', 'sardine', 'sardines',
          'mackerel', 'herring', 'swordfish', 'tilapia', 'catfish',
          'snapper', 'grouper', 'mahi mahi', 'caviar', 'roe',
          'sashimi', 'sushi', 'ceviche',
        ],
      ),
      Allergy(
        name: '大豆',
        nameEn: 'soy',
        keywords: [
          'soy', 'soya', 'soybean', 'soybeans', 'tofu', 'edamame',
          'tempeh', 'miso', 'natto', 'soy sauce', 'shoyu', 'tamari',
          'teriyaki', 'soy milk', 'soy protein', 'textured vegetable protein',
          'tvp', 'bean curd',
        ],
      ),
      Allergy(
        name: 'ゴマ',
        nameEn: 'sesame',
        keywords: [
          'sesame', 'tahini', 'sesame oil', 'sesame seed', 'sesame seeds',
          'gomasio', 'goma', 'sesamol',
        ],
      ),
      Allergy(
        name: 'マスタード',
        nameEn: 'mustard',
        keywords: [
          'mustard', 'dijon', 'whole grain mustard', 'mustard seed',
          'mustard seeds', 'mustard greens', 'karashi',
        ],
      ),
      Allergy(
        name: '硫酸塩',
        nameEn: 'sulfites',
        keywords: [
          'sulfite', 'sulfites', 'sulphite', 'sulphites', 'wine',
          'dried fruit', 'dried fruits',
        ],
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

  // テキストからアレルギー物質を検出（改良版）
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

      // キーワードマッチング（単語境界を考慮）
      for (final keyword in allergy.keywords) {
        // 完全一致または単語の一部としてマッチ
        final pattern = RegExp(r'\b' + RegExp.escape(keyword) + r'\b', caseSensitive: false);
        if (pattern.hasMatch(lowerText)) {
          if (!detectedAllergens.contains(allergy.name)) {
            detectedAllergens.add(allergy.name);
          }
          break;
        }
      }
    }

    return detectedAllergens;
  }

  // 料理名から推測されるアレルギー物質を検出
  List<String> detectAllergensFromDishName(String dishName, List<String> userAllergies) {
    final detected = <String>[];
    final lowerDish = dishName.toLowerCase();

    // よくある料理パターン
    final dishPatterns = {
      '小麦': [
        'pizza', 'pasta', 'noodle', 'ramen', 'udon', 'soba',
        'tempura', 'bread', 'sandwich', 'burger', 'burrito', 'taco',
        'cake', 'cookie', 'waffle', 'pancake',
      ],
      '卵': [
        'omelette', 'omelet', 'scrambled', 'fried egg', 'carbonara',
        'tamago', 'quiche', 'frittata', 'custard', 'meringue',
      ],
      '乳製品': [
        'cheese', 'pizza', 'alfredo', 'carbonara', 'creamy',
        'gratin', 'au gratin', 'ice cream', 'gelato', 'latte',
        'cappuccino', 'macchiato',
      ],
      '魚': [
        'sushi', 'sashimi', 'fish', 'salmon', 'tuna', 'cod',
      ],
      '甲殻類': [
        'shrimp', 'prawn', 'crab', 'lobster', 'seafood',
      ],
      '大豆': [
        'tofu', 'edamame', 'miso', 'teriyaki',
      ],
    };

    for (final allergyName in userAllergies) {
      if (dishPatterns.containsKey(allergyName)) {
        for (final pattern in dishPatterns[allergyName]!) {
          if (lowerDish.contains(pattern)) {
            if (!detected.contains(allergyName)) {
              detected.add(allergyName);
            }
            break;
          }
        }
      }
    }

    return detected;
  }

  // テキストと料理名の両方から総合的に判定
  List<String> detectAllergensComprehensive(
    String text,
    String translatedText,
    List<String> userAllergies,
  ) {
    final detected = <String>{};

    // 元のテキストから検出
    detected.addAll(detectAllergens(text, userAllergies));

    // 翻訳されたテキストから検出
    detected.addAll(detectAllergens(translatedText, userAllergies));

    // 料理名パターンから推測
    detected.addAll(detectAllergensFromDishName(translatedText, userAllergies));

    return detected.toList();
  }
}
