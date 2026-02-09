import 'package:json_annotation/json_annotation.dart';

part 'menu_item_result.g.dart';

enum RiskLevel {
  safe,
  caution,
  danger;

  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => RiskLevel.caution,
    );
  }
}

@JsonSerializable()
class MenuItemResult {
  final String name;
  final String? description;

  @JsonKey(name: 'risk_level', fromJson: _riskFromJson)
  final RiskLevel riskLevel;

  @JsonKey(name: 'confirmed_allergens')
  final List<String> confirmedAllergens;

  @JsonKey(name: 'likely_allergens')
  final List<String> likelyAllergens;

  @JsonKey(name: 'possible_allergens')
  final List<String> possibleAllergens;

  final String explanation;

  @JsonKey(name: 'waiter_question')
  final String waiterQuestion;

  const MenuItemResult({
    required this.name,
    this.description,
    required this.riskLevel,
    this.confirmedAllergens = const [],
    this.likelyAllergens = const [],
    this.possibleAllergens = const [],
    this.explanation = '',
    this.waiterQuestion = '',
  });

  factory MenuItemResult.fromJson(Map<String, dynamic> json) =>
      _$MenuItemResultFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemResultToJson(this);

  List<String> get allAllergens => [
        ...confirmedAllergens,
        ...likelyAllergens,
        ...possibleAllergens,
      ];

  static RiskLevel _riskFromJson(dynamic value) =>
      RiskLevel.fromString(value as String);
}
