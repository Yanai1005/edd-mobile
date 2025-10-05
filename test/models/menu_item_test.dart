import 'package:flutter_test/flutter_test.dart';
import 'package:allergy_guard/models/menu_item.dart';

void main() {
  group('MenuItem Model Tests', () {
    test('MenuItem should be created with correct properties', () {
      final menuItem = MenuItem(
        originalText: 'Grilled Salmon',
        translatedText: '焼きサーモン',
        detectedAllergens: ['魚'],
        isWarning: true,
      );

      expect(menuItem.originalText, 'Grilled Salmon');
      expect(menuItem.translatedText, '焼きサーモン');
      expect(menuItem.detectedAllergens, contains('魚'));
      expect(menuItem.isWarning, true);
    });

    test('MenuItem should have default empty allergens list', () {
      final menuItem = MenuItem(
        originalText: 'Vegetable Soup',
        translatedText: '野菜スープ',
      );

      expect(menuItem.detectedAllergens, isEmpty);
      expect(menuItem.isWarning, false);
    });

    test('MenuItem with allergens should have warning flag', () {
      final menuItem = MenuItem(
        originalText: 'Caesar Salad with cheese',
        translatedText: 'チーズ入りシーザーサラダ',
        detectedAllergens: ['乳製品'],
        isWarning: true,
      );

      expect(menuItem.isWarning, true);
      expect(menuItem.detectedAllergens.length, 1);
    });
  });
}
