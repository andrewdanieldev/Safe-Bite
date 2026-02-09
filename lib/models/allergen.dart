import 'package:hive/hive.dart';

part 'allergen.g.dart';

@HiveType(typeId: 0)
enum AllergenType {
  @HiveField(0)
  peanuts('Peanuts', '🥜'),
  @HiveField(1)
  treeNuts('Tree Nuts', '🌰'),
  @HiveField(2)
  dairy('Dairy', '🥛'),
  @HiveField(3)
  eggs('Eggs', '🥚'),
  @HiveField(4)
  wheat('Wheat / Gluten', '🌾'),
  @HiveField(5)
  soy('Soy', '🫘'),
  @HiveField(6)
  fish('Fish', '🐟'),
  @HiveField(7)
  shellfish('Shellfish', '🦐'),
  @HiveField(8)
  sesame('Sesame', '🫘'),
  @HiveField(9)
  mustard('Mustard', '🟡'),
  @HiveField(10)
  celery('Celery', '🥬'),
  @HiveField(11)
  lupin('Lupin', '🌿'),
  @HiveField(12)
  mollusks('Mollusks', '🐚'),
  @HiveField(13)
  sulfites('Sulfites', '🍷'),
  @HiveField(14)
  custom('Custom', '⚠️');

  const AllergenType(this.label, this.emoji);
  final String label;
  final String emoji;
}

@HiveType(typeId: 1)
enum Severity {
  @HiveField(0)
  mild('Mild', 'Discomfort or minor symptoms'),
  @HiveField(1)
  moderate('Moderate', 'Significant allergic reaction'),
  @HiveField(2)
  severe('Severe', 'Anaphylaxis risk');

  const Severity(this.label, this.description);
  final String label;
  final String description;
}

@HiveType(typeId: 2)
class Allergen extends HiveObject {
  @HiveField(0)
  final AllergenType type;

  @HiveField(1)
  final String? customName;

  @HiveField(2)
  final Severity severity;

  Allergen({
    required this.type,
    this.customName,
    this.severity = Severity.moderate,
  });

  String get displayName =>
      type == AllergenType.custom ? (customName ?? 'Custom') : type.label;

  String get emoji => type.emoji;

  Allergen copyWith({Severity? severity, String? customName}) {
    return Allergen(
      type: type,
      customName: customName ?? this.customName,
      severity: severity ?? this.severity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Allergen &&
          type == other.type &&
          customName == other.customName;

  @override
  int get hashCode => type.hashCode ^ (customName?.hashCode ?? 0);
}
