import 'package:flutter_test/flutter_test.dart';
import 'package:allergy_guard/services/allergy_service.dart';

void main() {
  group('AllergyService Tests', () {
    late AllergyService service;

    setUp(() {
      service = AllergyService();
    });

    test('getAllergies should return list of allergies', () {
      final allergies = AllergyService.getAllergies();

      expect(allergies, isNotEmpty);
      expect(allergies.length, 9);
      expect(allergies.any((a) => a.name == '小麦'), true);
      expect(allergies.any((a) => a.name == '卵'), true);
    });

    test('detectAllergens should find wheat in text', () {
      const text = 'Grilled chicken with bread and butter';
      final userAllergies = ['小麦'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected, contains('小麦'));
    });

    test('detectAllergens should find multiple allergens', () {
      const text = 'Caesar Salad with cheese, eggs, and bread';
      final userAllergies = ['小麦', '卵', '乳製品'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected.length, 3);
      expect(detected, contains('小麦'));
      expect(detected, contains('卵'));
      expect(detected, contains('乳製品'));
    });

    test('detectAllergens should be case insensitive', () {
      const text = 'GRILLED SALMON WITH BUTTER SAUCE';
      final userAllergies = ['魚', '乳製品'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected, contains('魚'));
      expect(detected, contains('乳製品'));
    });

    test('detectAllergens should return empty list when no allergens found', () {
      const text = 'Vegetable soup with rice';
      final userAllergies = ['卵', '乳製品'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected, isEmpty);
    });

    test('detectAllergens should detect shrimp as shellfish', () {
      const text = 'Shrimp tempura';
      final userAllergies = ['甲殻類'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected, contains('甲殻類'));
    });

    test('detectAllergens should detect peanut butter', () {
      const text = 'Chicken with peanut sauce';
      final userAllergies = ['ピーナッツ'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected, contains('ピーナッツ'));
    });

    test('detectAllergens should not duplicate allergens', () {
      const text = 'Bread with cheese and more bread';
      final userAllergies = ['小麦', '乳製品'];

      final detected = service.detectAllergens(text, userAllergies);

      expect(detected.length, 2);
      expect(detected.where((a) => a == '小麦').length, 1);
    });
  });
}
