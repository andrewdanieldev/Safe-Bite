// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemResult _$MenuItemResultFromJson(Map<String, dynamic> json) =>
    MenuItemResult(
      name: json['name'] as String,
      description: json['description'] as String?,
      riskLevel: MenuItemResult._riskFromJson(json['risk_level']),
      confirmedAllergens: (json['confirmed_allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      likelyAllergens: (json['likely_allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      possibleAllergens: (json['possible_allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      explanation: json['explanation'] as String? ?? '',
      waiterQuestion: json['waiter_question'] as String? ?? '',
    );

Map<String, dynamic> _$MenuItemResultToJson(MenuItemResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'risk_level': instance.riskLevel.name,
      'confirmed_allergens': instance.confirmedAllergens,
      'likely_allergens': instance.likelyAllergens,
      'possible_allergens': instance.possibleAllergens,
      'explanation': instance.explanation,
      'waiter_question': instance.waiterQuestion,
    };
