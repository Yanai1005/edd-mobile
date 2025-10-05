class Allergy {
  final String name;
  final String nameEn;
  final List<String> keywords;

  Allergy({
    required this.name,
    required this.nameEn,
    required this.keywords,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      keywords: List<String>.from(json['keywords'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameEn': nameEn,
      'keywords': keywords,
    };
  }
}
