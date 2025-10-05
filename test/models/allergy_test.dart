import 'package:flutter_test/flutter_test.dart';
import 'package:allergy_guard/models/allergy.dart';

void main() {
  group('Allergy Model Tests', () {
    test('Allergy model should be created with correct properties', () {
      final allergy = Allergy(
        name: '小麦',
        nameEn: 'wheat',
        keywords: ['wheat', 'flour', 'bread'],
      );

      expect(allergy.name, '小麦');
      expect(allergy.nameEn, 'wheat');
      expect(allergy.keywords.length, 3);
      expect(allergy.keywords, contains('wheat'));
    });

    test('Allergy model should serialize to JSON correctly', () {
      final allergy = Allergy(
        name: '卵',
        nameEn: 'egg',
        keywords: ['egg', 'eggs'],
      );

      final json = allergy.toJson();

      expect(json['name'], '卵');
      expect(json['nameEn'], 'egg');
      expect(json['keywords'], isA<List>());
      expect(json['keywords'], contains('egg'));
    });

    test('Allergy model should deserialize from JSON correctly', () {
      final json = {
        'name': '乳製品',
        'nameEn': 'milk',
        'keywords': ['milk', 'dairy', 'cheese'],
      };

      final allergy = Allergy.fromJson(json);

      expect(allergy.name, '乳製品');
      expect(allergy.nameEn, 'milk');
      expect(allergy.keywords.length, 3);
      expect(allergy.keywords, contains('cheese'));
    });
  });
}
